import settings;
import three;
import solids;unitsize(4cm);

currentprojection=perspective( camera = (1.0, 1.0, 0.0), target = (0.0, 0.0, 0.0) );
currentlight=nolight;

revolution S=sphere(O,1);
pen SpherePen = rgb(0.85,0.85,0.85)+opacity(0.6);
pen SphereLinePen = rgb(0.75,0.75,0.75)+opacity(0.6)+linewidth(0.5pt);
draw(surface(S), surfacepen=SpherePen, meshpen=SphereLinePen);

/*
  Colors
*/
pen curveStyle1 = rgb(0.0,0.0,0.0)+linewidth(0.75pt)+opacity(1.0);
pen pointStyle1 = rgb(0.9333333333333333,0.4666666666666667,0.2)+linewidth(3.5pt)+opacity(1.0);
pen pointStyle2 = rgb(0.2,0.7333333333333333,0.9333333333333333)+linewidth(2.0pt)+opacity(1.0);
pen tVectorStyle1 = rgb(0.2,0.7333333333333333,0.9333333333333333)+linewidth(0.75pt)+linewidth(0.75pt)+opacity(1.0);
pen tVectorStyle2 = rgb(0.2,0.7333333333333333,0.9333333333333333)+linewidth(0.75pt)+linewidth(0.75pt)+opacity(1.0);
pen tVectorStyle3 = rgb(0.0,0.6,0.5333333333333333)+linewidth(0.75pt)+linewidth(0.75pt)+opacity(1.0);

/*
  Exported Points
*/
dot( (1.0,0.0,0.0), pointStyle1);
dot( (0.0,1.0,0.0), pointStyle1);
dot( (1.0,0.0,0.0), pointStyle2);
dot( (0.9876883405951378,0.15643446504023087,0.0), pointStyle2);
dot( (0.9510565162951535,0.3090169943749474,0.0), pointStyle2);
dot( (0.8910065241883679,0.45399049973954675,0.0), pointStyle2);
dot( (0.8090169943749475,0.5877852522924731,0.0), pointStyle2);
dot( (0.7071067811865476,0.7071067811865475,0.0), pointStyle2);
dot( (0.5877852522924731,0.8090169943749475,0.0), pointStyle2);
dot( (0.45399049973954686,0.8910065241883678,0.0), pointStyle2);
dot( (0.30901699437494745,0.9510565162951536,0.0), pointStyle2);
dot( (0.15643446504023092,0.9876883405951378,0.0), pointStyle2);
dot( (6.123233995736766e-17,1.0,0.0), pointStyle2);

/*
  Exported Curves
*/
path3 p1 = (1.0,0.0,0.0) .. (0.9876883405951378,0.15643446504023087,0.0) .. (0.9510565162951535,0.3090169943749474,0.0) .. (0.8910065241883679,0.45399049973954675,0.0) .. (0.8090169943749475,0.5877852522924731,0.0) .. (0.7071067811865476,0.7071067811865475,0.0) .. (0.5877852522924731,0.8090169943749475,0.0) .. (0.45399049973954686,0.8910065241883678,0.0) .. (0.30901699437494745,0.9510565162951536,0.0) .. (0.15643446504023092,0.9876883405951378,0.0) .. (6.123233995736766e-17,1.0,0.0);
 draw(p1, curveStyle1);

/*
  Exported tangent vectors
*/
draw( (1.0,0.0,0.0)--(1.0,0.4,0.5), tVectorStyle1,Arrow3(6.0));
draw( (0.9876883405951378,0.15643446504023087,0.0)--(0.9313719331806547,0.5120022676544805,0.4938441702975689), tVectorStyle1,Arrow3(6.0));
draw( (0.9510565162951535,0.3090169943749474,0.0)--(0.8521710780951703,0.6133550795893966,0.47552825814757677), tVectorStyle1,Arrow3(6.0));
draw( (0.8910065241883679,0.45399049973954675,0.0)--(0.7638891842612948,0.7034723265122897,0.4455032620941839), tVectorStyle1,Arrow3(6.0));
draw( (0.8090169943749475,0.5877852522924731,0.0)--(0.6679485338247539,0.7819493309424606,0.4045084971874737), tVectorStyle1,Arrow3(6.0));
draw( (0.7071067811865476,0.7071067811865475,0.0)--(0.565685424949238,0.848528137423857,0.35355339059327373), tVectorStyle1,Arrow3(6.0));
draw( (0.5877852522924731,0.8090169943749475,0.0)--(0.4583425331924815,0.9030626347417432,0.29389262614623657), tVectorStyle1,Arrow3(6.0));
draw( (0.45399049973954686,0.8910065241883678,0.0)--(0.3470697168369427,0.9454853841571135,0.2269952498697734), tVectorStyle1,Arrow3(6.0));
draw( (0.30901699437494745,0.9510565162951536,0.0)--(0.2329324730713352,0.9757778758451494,0.15450849718747367), tVectorStyle1,Arrow3(6.0));
draw( (0.15643446504023092,0.9876883405951378,0.0)--(0.11692693141642542,0.993945719196747,0.07821723252011542), tVectorStyle1,Arrow3(6.0));
draw( (6.123233995736766e-17,1.0,0.0)--(6.123233995736766e-17,1.0,0.0), tVectorStyle1,Arrow3(6.0));
draw( (1.0,0.0,0.0)--(1.0,0.0,0.0), tVectorStyle2,Arrow3(6.0));
draw( (0.9876883405951378,0.15643446504023087,0.0)--(0.9908170298959423,0.13668069822832812,-0.07821723252011542), tVectorStyle2,Arrow3(6.0));
draw( (0.9510565162951535,0.3090169943749474,0.0)--(0.9634171960701514,0.27097473372314124,-0.15450849718747367), tVectorStyle2,Arrow3(6.0));
draw( (0.8910065241883679,0.45399049973954675,0.0)--(0.9182459541727407,0.40053010828824465,-0.2269952498697734), tVectorStyle2,Arrow3(6.0));
draw( (0.8090169943749475,0.5877852522924731,0.0)--(0.8560398145583453,0.5230638927424773,-0.29389262614623657), tVectorStyle2,Arrow3(6.0));
draw( (0.7071067811865476,0.7071067811865475,0.0)--(0.7778174593052023,0.6363961030678927,-0.35355339059327373), tVectorStyle2,Arrow3(6.0));
draw( (0.5877852522924731,0.8090169943749475,0.0)--(0.6848672916174668,0.7384827640998507,-0.4045084971874737), tVectorStyle2,Arrow3(6.0));
draw( (0.45399049973954686,0.8910065241883678,0.0)--(0.5787314131259184,0.8274478542248312,-0.4455032620941839), tVectorStyle2,Arrow3(6.0));
draw( (0.30901699437494745,0.9510565162951536,0.0)--(0.4611860369821721,0.9016137971951621,-0.47552825814757677), tVectorStyle2,Arrow3(6.0));
draw( (0.15643446504023092,0.9876883405951378,0.0)--(0.33421836634735574,0.9595301368878962,-0.4938441702975689), tVectorStyle2,Arrow3(6.0));
draw( (6.123233995736766e-17,1.0,0.0)--(0.20000000000000007,1.0,-0.5), tVectorStyle2,Arrow3(6.0));
draw( (1.0,0.0,0.0)--(1.0,0.4,0.5), tVectorStyle3,Arrow3(6.0));
draw( (0.9876883405951378,0.15643446504023087,0.0)--(0.9345006224814593,0.49224850084257776,0.41562693777745346), tVectorStyle3,Arrow3(6.0));
draw( (0.9510565162951535,0.3090169943749474,0.0)--(0.8645317578701682,0.5753128189375905,0.3210197609601031), tVectorStyle3,Arrow3(6.0));
draw( (0.8910065241883679,0.45399049973954675,0.0)--(0.7911286142456676,0.6500119350609876,0.2185080122244105), tVectorStyle3,Arrow3(6.0));
draw( (0.8090169943749475,0.5877852522924731,0.0)--(0.7149713540081518,0.7172279713924647,0.11061587104123716), tVectorStyle3,Arrow3(6.0));
draw( (0.7071067811865476,0.7071067811865475,0.0)--(0.6363961030678928,0.7778174593052023,0.0), tVectorStyle3,Arrow3(6.0));
draw( (0.5877852522924731,0.8090169943749475,0.0)--(0.5554245725174752,0.8325284044666464,-0.11061587104123716), tVectorStyle3,Arrow3(6.0));
draw( (0.45399049973954686,0.8910065241883678,0.0)--(0.4718106302233142,0.8819267141935769,-0.2185080122244105), tVectorStyle3,Arrow3(6.0));
draw( (0.30901699437494745,0.9510565162951536,0.0)--(0.38510151567855977,0.9263351567451579,-0.3210197609601031), tVectorStyle3,Arrow3(6.0));
draw( (0.15643446504023092,0.9876883405951378,0.0)--(0.29471083272355025,0.9657875154895055,-0.41562693777745346), tVectorStyle3,Arrow3(6.0));
draw( (6.123233995736766e-17,1.0,0.0)--(0.20000000000000007,1.0,-0.5), tVectorStyle3,Arrow3(6.0));
