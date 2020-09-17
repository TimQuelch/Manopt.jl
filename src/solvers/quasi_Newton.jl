@doc raw"""
    quasi_Newton(M, F, ∇F, x, H, )

evaluate a Riemannian quasi-Newton solver for optimization on manifolds.
It will attempt to minimize the cost function F on the Manifold M.

# Input
* `M` – a manifold $\mathcal{M}$
* `F` – a cost function $F \colon \mathcal{M} \to \mathbb{R}$ to minimize
* `∇F`- the gradient $\nabla F \colon \mathcal M \to \tangent{x}$ of $F$
* `x` – an initial value $x \in \mathcal{M}$

# Optional

# Output
* `x` – the last reached point on the manifold

# see also

"""
function quasi_Newton(
    M::MT,
    F::Function,
    ∇F::Function,
    x;
    retraction_method::AbstractRetractionMethod = ExponentialRetraction(),
    vector_transport_method::AbstractVectorTransportMethod = ParallelTransport(),
    broyden_factor::Float64 = 0.0,
    cautious_update::Bool=false,
    cautious_function::Function = (x) -> x*10^-4,
    memory_size::Int = 20,
    memory_steps = [zero_tangent_vector(M,x) for _ ∈ 1:memory_size],
    memory_gradients = [zero_tangent_vector(M,x) for _ ∈ 1:memory_size],
    memory_position = 0,
    step_size::Stepsize = ConstantStepsize(1.0),
    stopping_criterion::StoppingCriterion = StopWhenAny(
        StopAfterIteration(max(1000, memory_size)),
        StopWhenGradientNormLess(10^(-6))),
	return_options=false,
    kwargs...
) where {MT <: Manifold}

	(broyden_factor < 0. || broyden_factor > 1.) && throw( ErrorException( "broyden_factor must be in the interval [0,1], but it is $broyden_factor."))

	memory_steps_size = length(memory_steps)
	g = length(memory_gradients)

	(memory_steps_size != g) && throw( ErrorException( "The number of given vectors in memory_steps ($memory_steps_size) is different from the number of memory_gradients ($g)."))

	(memory_steps_size < memory_position) && throw( ErrorException( "The number of given vectors in memory_steps ($memory_steps_size) is too small compared to memory_position ($memory_position)."))

	if memory_size < 0 && memory_steps_size == 0
		grad_x = ∇F(x)
		approximation = get_vectors(M, x, get_basis(M, x, DefaultOrthonormalBasis()))
		if cautious_update == true
			o = CautiuosQuasiNewtonOptions(x, grad_x, approximation; cautious_function = cautious_function, retraction_method = retraction_method, vector_transport_method = vector_transport_method, stop = stopping_criterion, stepsize = step_size, broyden_factor = broyden_factor)
		else
			o = QuasiNewtonOptions(x, grad_x, approximation; retraction_method = retraction_method, vector_transport_method = vector_transport_method, stop = stopping_criterion, stepsize = step_size, broyden_factor = broyden_factor)
		end
	else
		if cautious_update == true
			o = CautiuosRLBFGSOptions(x, memory_gradients, memory_steps; cautious_function = cautious_function, current_memory_size = memory_position, retraction_method = retraction_method, vector_transport_method = vector_transport_method, stop = stopping_criterion, stepsize = step_size)
		else
			o = RLBFGSOptions(x, memory_gradients, memory_steps; current_memory_size = memory_position, retraction_method = retraction_method, vector_transport_method = vector_transport_method, stop = stopping_criterion, stepsize = step_size)
		end
	end

	p = GradientProblem(M,F,∇F)

	o = decorate_options(o; kwargs...)
	resultO = solve(p,o)

	if return_options
		return resultO
	else
		return get_solver_result(resultO)
	end
end


function initialize_solver!(p::GradientProblem,o::AbstractQuasiNewtonOptions)
end

function step_solver!(p::GradientProblem,o::AbstractQuasiNewtonOptions,iter)
	η = get_quasi_newton_direction(p, o)
	α = o.stepsize(p,o,iter,η)
	x_old = o.x
	o.x = retract(p.M, o.x, α*η, o.retraction_method)
	update_parameters(p, o, α, η, x_old)
end

# Computing the direction

function get_quasi_newton_direction(p::GradientProblem, o::Union{QuasiNewtonOptions{P,T}, CautiuosQuasiNewtonOptions{P,T}}) where {P, T}
	o.∇ = get_gradient(p,o.x)
	return square_matrix_vector_product(p.M, o.x, o.inverse_hessian_approximation, -o.∇)
end

# Limited memory variants

function get_quasi_newton_direction(p::GradientProblem, o::Union{RLBFGSOptions{P,T}, CautiuosRLBFGSOptions{P,T}}) where {P, T}
	q = get_gradient(p,o.x)
	o.current_memory_size

	inner_s_q = zeros(o.current_memory_size)

	for i in o.current_memory_size : -1 : 1
		inner_s_q[i] = inner(p.M, o.x, o.steps[i], q) / inner(p.M, o.x, o.steps[i], o.gradient_diffrences[i])
		q =  q - inner_s_q[i]*o.gradient_diffrences[i]
	end

	if o.current_memory_size <= 1
		r = q
	else
		r = (inner(p.M, o.x, o.steps[o.current_memory_size - 1], o.gradient_diffrences[o.current_memory_size - 1]) / norm(p.M, o.x, o.gradient_diffrences[o.current_memory_size - 1])^2) * q
	end

	for i in 1 : o.current_memory_size
		omega = inner(p.M, o.x, o.gradient_diffrences[i], r) / inner(p.M, o.x, o.steps[i], o.gradient_diffrences[i])
		r = r + (inner_s_q[i] + omega) * o.steps[i]
	end

	return -r
end


# Updating the parameters

function update_parameters(p::GradientProblem, o::QuasiNewtonOptions{P,T}, α::Float64, η::T, x::P) where {P,T}
	gradf_xold = o.∇
	β = norm(p.M, x, α*η) / norm(p.M, o.x, vector_transport_to(p.M, x, α*η, o.x, o.vector_transport_method))
	yk = β*get_gradient(p,o.x) - vector_transport_to(p.M, x, gradf_xold, o.x, o.vector_transport_method)
	sk = vector_transport_to(p.M, x, α*η, o.x, o.vector_transport_method)

	b = [ vector_transport_to(p.M, x, v, o.x, o.vector_transport_method) for v ∈ o.inverse_hessian_approximation ]
	basis = get_vectors(p.M, o.x, get_basis(p.M, o.x, DefaultOrthonormalBasis()))

	n = manifold_dimension(p.M)
	Bkyk = square_matrix_vector_product(p.M, o.x, b, yk; orthonormal_basis = basis)
	skyk = inner(p.M, o.x, yk, sk)

	if o.broyden_factor==1.0
		new_approx = update_Newton_Hessian(p.M, o.x, b, basis, sk, yk, Bkyk, skyk, n, Val(:DFP))
		for i = 1:n
			o.inverse_hessian_approximation[i] = new_approx[i]
		end
	end

	# (o.broyden_factor==1.0) && o.inverse_hessian_approximation .= update_Newton_Hessian(p.M, o.x, b, basis, sk, yk, Bkyk, skyk, n, Val(:DFP))

	if o.broyden_factor==0.0
		new_approx = update_Newton_Hessian(p.M, o.x, b, basis, sk, yk, Bkyk, skyk, n, Val(:BFGS))
		for i = 1:n
			o.inverse_hessian_approximation[i] = new_approx[i]
		end
	end

	# (o.broyden_factor==0.0) && o.inverse_hessian_approximation .= update_Newton_Hessian(p.M, o.x, b, basis, sk, yk, Bkyk, skyk, n, Val(:BFGS))

	if o.broyden_factor > 0 && o.broyden_factor < 1
		X .= update_Newton_Hessian(p.M, o.x, b, basis, sk, yk, Bkyk, skyk, n, Val(:BFGS))
		Y .= update_Newton_Hessian(p.M, o.x, b, basis, sk, yk, Bkyk, skyk, n, Val(:DFP))
		o.inverse_hessian_approximation .= [ o.broyden_factor*x + (1 - o.broyden_factor) * y for (x,y) ∈ zip(X,Y) ]
	end
end

function update_parameters(p::GradientProblem, o::CautiuosQuasiNewtonOptions{P,T}, α::Float64, η::T, x::P) where {P,T}
	gradf_xold = o.∇
	β = norm(p.M, x, α*η) / norm(p.M, x, vector_transport_to(p.M, x, α*η, o.x, o.vector_transport_method))
	yk = β*get_gradient(p,o.x) - vector_transport_to(p.M, x, gradf_xold, o.x, o.vector_transport_method)
	sk = vector_transport_to(p.M, x, α*η, o.x, o.vector_transport_method)

	skyk = inner(p.M, o.x, yk, sk)
	norm_sk = norm(p.M, o.x, sk)

	bound = o.cautious_fct(norm(p.M, x, gradf_xold))

	if norm_sk != 0 && (skyk / norm_sk) >= bound
		b = [ vector_transport_to(p.M, x, v, o.x, o.vector_transport_method) for v ∈ o.inverse_hessian_approximation ]
		basis = get_vectors(p.M, o.x, get_basis(p.M, o.x, DefaultOrthonormalBasis()))

		n = manifold_dimension(p.M)
		Bkyk = square_matrix_vector_product(p.M, o.x, b, yk; orthonormal_basis = basis)

		if o.broyden_factor==1.0
			new_approx = update_Newton_Hessian(p.M, o.x, b, basis, sk, yk, Bkyk, skyk, n, Val(:DFP))
			for i = 1:n
				o.inverse_hessian_approximation[i] = new_approx[i]
			end
		end

		# (o.broyden_factor==1.0) && o.inverse_hessian_approximation .= update_Newton_Hessian(p.M, o.x, b, basis, sk, yk, Bkyk, skyk, n, Val(:DFP))

		if o.broyden_factor==0.0
			new_approx = update_Newton_Hessian(p.M, o.x, b, basis, sk, yk, Bkyk, skyk, n, Val(:BFGS))
			for i = 1:n
				o.inverse_hessian_approximation[i] = new_approx[i]
			end
		end

		# (o.broyden_factor==0.0) && o.inverse_hessian_approximation .= update_Newton_Hessian(p.M, o.x, b, basis, sk, yk, Bkyk, skyk, n, Val(:BFGS))

		if o.broyden_factor > 0 && o.broyden_factor < 1
			X .= update_Newton_Hessian(p.M, o.x, b, basis, sk, yk, Bkyk, skyk, n, Val(:BFGS))
			Y .= update_Newton_Hessian(p.M, o.x, b, basis, sk, yk, Bkyk, skyk, n, Val(:DFP))
			o.inverse_hessian_approximation .= [ o.broyden_factor*x + (1 - o.broyden_factor) * y for (x,y) ∈ zip(X,Y) ]
		end
	else
		o.inverse_hessian_approximation = vector_transport_to.(p.M, x, o.inverse_hessian_approximation, o.x, o.vector_transport_method)
	end

end

function update_Newton_Hessian(M::Manifold, p::P, b::AbstractVector{T}, basis::AbstractVector{T}, sk::T, yk::T, Bkyk::T, skyk::Float64, n::Int, ::Val{:BFGS}) where {P,T}
	return [b[i] - (inner(M, p, basis[i], sk) / skyk) * Bkyk - (inner(M, p, Bkyk, basis[i]) / skyk) * sk + ((inner(M, p, yk, Bkyk)*inner(M, p, sk, basis[i])) / skyk^2) * sk + (inner(M, p, sk, basis[i])
	/ skyk) * sk for i ∈ 1:n]
end

function update_Newton_Hessian(M::Manifold, p::P, b::AbstractVector{T}, basis::AbstractVector{T}, sk::T, yk::T, Bkyk::T, skyk::Float64, n::Int, ::Val{:DFP}) where {P,T}
	# I need to implement a DFP Update
	return get_vectors(M, p, get_basis(M, p, DefaultOrthonormalBasis()))
end

# Limited memory variants

function update_parameters(p::GradientProblem, o::RLBFGSOptions{P,T}, α::Float64, η::T, xk::P) where {P,T}
        gradf_xold = get_gradient(p,xk)
        β = norm(p.M, xk, α*η) / norm(p.M, o.x, vector_transport_to(p.M, xk, α*η, o.x, o.vector_transport_method))
        yk = β*get_gradient(p,o.x) - vector_transport_to(p.M, xk, gradf_xold, o.x, o.vector_transport_method)
        sk = vector_transport_to(p.M, xk, α*η, o.x, o.vector_transport_method)
		memory_steps_size = length(o.steps)

        if o.current_memory_size >= memory_steps_size
                for  i in 2 : memory_steps_size
                        o.steps[i] = vector_transport_to(p.M, xk, o.steps[i], o.x, o.vector_transport_method)
                        o.gradient_diffrences[i] = vector_transport_to(p.M, xk, o.gradient_diffrences[i], o.x, o.vector_transport_method)
                end

                if memory_steps_size > 1
                        o.steps = o.steps[2:end]
                        o.gradient_diffrences = o.gradient_diffrences[2:end]
                end

                if memory_steps_size > 0
                        o.steps[memory_steps_size] = sk
                        o.gradient_diffrences[memory_steps_size] = yk
                end
        else

                for i in 1:o.current_memory_size
                        o.steps[i] = vector_transport_to(p.M, xk, o.steps[i], o.x, o.vector_transport_method)
                        o.gradient_diffrences[i] = vector_transport_to(p.M, xk, o.gradient_diffrences[i], o.x, o.vector_transport_method)
                end

                o.steps[o.current_memory_size + 1] = sk
                o.gradient_diffrences[o.current_memory_size + 1] = yk

                o.current_memory_size = o.current_memory_size + 1
        end
end


function update_parameters(p::GradientProblem, o::CautiuosRLBFGSOptions{P,T}, α::Float64, η::T, x::P) where {P,T}
        gradf_xold = get_gradient(p,x)
        β = norm(p.M, x, α*η) / norm(p.M, x, vector_transport_to(p.M, x, α*η, o.x, o.vector_transport_method))
        yk = β*get_gradient(p,o.x) - vector_transport_to(p.M, x, gradf_xold, o.x, o.vector_transport_method)
        sk = vector_transport_to(p.M, x, α*η, o.x, o.vector_transport_method)

        sk_yk = inner(p.M, o.x, sk, yk)
        norm_sk = norm(p.M, o.x, sk)
        bound = o.cautious_fct(norm(p.M, x, get_gradient(p,x)))

        if norm_sk != 0 && (sk_yk / norm_sk) >= bound
                if o.current_memory_size >= memory_steps_size
                        for  i in 2 : memory_steps_size
                                vector_transport_to(p.M, x, o.steps[i], o.x, o.vector_transport_method)
                                o.steps[i] = vector_transport_to(p.M, x, o.steps[i], o.x, o.vector_transport_method)
                                o.gradient_diffrences[i] = vector_transport_to(p.M, x, o.gradient_diffrences[i], o.x, o.vector_transport_method)
                        end

                        if memory_steps_size > 1
                                o.steps = o.steps[2:end]
                                o.gradient_diffrences = o.gradient_diffrences[2:end]
                        end

                        if memory_steps_size > 0
                                o.steps[memory_steps_size] = sk
                                o.gradient_diffrences[memory_steps_size] = yk
                        end
                else

                        for i in 1:o.current_memory_size
                                o.steps[i] = vector_transport_to(p.M, x, o.steps[i], o.x, o.vector_transport_method)
                                o.gradient_diffrences[i] = vector_transport_to(p.M, x, o.gradient_diffrences[i], o.x, o.vector_transport_method)
                        end

                        o.steps[o.current_memory_size+1] = sk
                        o.gradient_diffrences[o.current_memory_size+1] = yk

                        o.current_memory_size = o.current_memory_size + 1
                end
        else
                for  i = 1 : min(o.current_memory_size, memory_steps_size)
                        o.steps[i] = o.Vector_Transport(p.M, x, o.x, o.steps[i])
                        o.gradient_diffrences[i] = o.Vector_Transport(p.M, x, o.x, o.gradient_diffrences[i])
                end
        end

end

import ManifoldsBase

function square_matrix_vector_product(M::Manifold, p::P, A::AbstractVector{T}, X::T; orthonormal_basis::AbstractVector{T} = get_vectors(M, p, get_basis(M, p, DefaultOrthonormalBasis()))) where {P,T}
        Y = zero_tangent_vector(M,p)
        n = manifold_dimension(M)
        for i in 1 : n
                Y = Y + inner(M, p, A[i], X) * orthonormal_basis[i]
        end
        return Y
end


get_solver_result(o::O) where {O <: AbstractQuasiNewtonOptions} = o.x