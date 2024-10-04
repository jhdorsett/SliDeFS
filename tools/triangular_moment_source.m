function [u1,u2,e11,e12,e22] = triangular_moment_source(nodes,obs_xy,u)

%Displacements and strains due to force couples in a thin elastic plate.
%This is the solution for uniform force couple over triangular source. 
%Solution for force couples was obtained analytical by differention point
%source analytical soultion.  Integration over the triangular area is
%performed numerically using a substituion of variable technique. NOTE:
%Solution for strains within the triangle was not stable, so I compute a
%finite difference of displacements to get strain at the centroid of the
%triangle. This solution outputs the centroid value for all points within
%the triangle. 






x1 = nodes(1,1); y1 = nodes(1,2);
x2 = nodes(2,1); y2 = nodes(2,2);
x3 = nodes(3,1); y3 = nodes(3,2);


xo = obs_xy(:,1);
yo = obs_xy(:,2);

%Strains at points within the triangle are poorly computed with the above
%integration scheme (not sure why). So, take finite differences for those
%points.
dx = (max(nodes(:,1)) - min(nodes(:,1)))/10;
dy = (max(nodes(:,2)) - min(nodes(:,2)))/10;

%make finite difference grid
centroid_xy = [ mean(nodes(:,1))+dx/2 mean(nodes(:,2)); mean(nodes(:,1))-dx/2 mean(nodes(:,2)); ...
    mean(nodes(:,1)) mean(nodes(:,2))+dy/2;  mean(nodes(:,1)) mean(nodes(:,2))-dy/2];

%integrate from 0,1-t ds and 0,1 dt

T = linspace(0,1,10);
S = linspace(0,1,10);


%gij gives displacement in i direction due to point force in j direction
%dgijdxk gives displacement in i diretion due to derivative of source xk
%   position, i.e., a force couple (moment) source
%DdgijdxkDx gives is spatial gradient with respect to observation coordinate 
%   for the force couple source, so these terms are used to compute strains
N = size(obs_xy,1);

dg11dx1 = zeros(N,1);
dg12dx1 = zeros(N,1);
dg22dx1 = zeros(N,1);

dg11dx2 = zeros(N,1);
dg12dx2 = zeros(N,1);
dg22dx2 = zeros(N,1);


dg11dx1_centroid = zeros(4,1);
dg12dx1_centroid = zeros(4,1);
dg22dx1_centroid = zeros(4,1);

dg11dx2_centroid = zeros(4,1);
dg12dx2_centroid = zeros(4,1);
dg22dx2_centroid = zeros(4,1);

Ddg11dx1Dx  = zeros(N,1);
Ddg11dx1Dy = zeros(N,1);
Ddg11dx2Dx = zeros(N,1);
Ddg11dx2Dy = zeros(N,1);

Ddg12dx1Dx  = zeros(N,1);
Ddg12dx1Dy = zeros(N,1);
Ddg12dx2Dx = zeros(N,1);
Ddg12dx2Dy = zeros(N,1);

Ddg22dx1Dx  = zeros(N,1);
Ddg22dx1Dy = zeros(N,1);
Ddg22dx2Dx = zeros(N,1);
Ddg22dx2Dy = zeros(N,1);

ds = S(2)-S(1);
dt = T(2)-T(1);

for k=1:length(T)

    t = T(k);

    for j=1:sum(S<=(1-t))

        s = S(j);

        %displacements

        term = @(xo,yo) (2*(1 + u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo).* ...
                (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2) ./ ...
             ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 + ...
                  (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^2 - ...
           ((3 - u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo))./ ...
             ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 + ...
                (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2);

        %evaluate at observation coordinates
        dg11dx1 = dg11dx1 - term(obs_xy(:,1),obs_xy(:,2))*ds*dt ;  %minus sign to make sources consistent with usual sign convention

        %evaluation at centroid points for finite difference
        dg11dx1_centroid = dg11dx1_centroid - term(centroid_xy(:,1),centroid_xy(:,2))*ds*dt;
        
        

        term = @(xo,yo)(2*(1 + u)*(-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^3)./ ...
       ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
         (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^2 -  ...
      ((3 - u)*(-((1 - s - t)*y1) - t*y2 - s*y3 + yo))./ ...
       ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
        (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2) -  ...
      (2*(1 + u)*(-((1 - s - t)*y1) - t*y2 - s*y3 + yo))./ ...
       ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
        (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2) ;
    
       
        %evaluate at observation coordinates
        dg11dx2 = dg11dx2 - term(obs_xy(:,1),obs_xy(:,2))*ds*dt ;  %minus sign to make sources consistent with usual sign convention

        %evaluation at centroid points for finite difference
        dg11dx2_centroid = dg11dx2_centroid - term(centroid_xy(:,1),centroid_xy(:,2))*ds*dt;
     


        term = @(xo,yo)(2*(-1 - u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2.* ...
            (-((1 - s - t)*y1) - t*y2 - s*y3 + yo))./ ...
         ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
              (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^2 -  ...
       ((-1 - u)*(-((1 - s - t)*y1) - t*y2 - s*y3 + yo))./ ...
         ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
            (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2);

   
        %evaluate at observation coordinates
        dg12dx1 = dg12dx1 - term(obs_xy(:,1),obs_xy(:,2))*ds*dt ;  %minus sign to make sources consistent with usual sign convention

        %evaluation at centroid points for finite difference
        dg12dx1_centroid = dg12dx1_centroid - term(centroid_xy(:,1),centroid_xy(:,2))*ds*dt;


            term = @(xo,yo)(2*(-1 - u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo).* ...
        (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2)./ ...
     ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
          (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^2 -  ...
   ((-1 - u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo))./ ...
     ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
        (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2);

        %evaluate at observation coordinates
        dg12dx2 = dg12dx2 - term(obs_xy(:,1),obs_xy(:,2))*ds*dt ;  %minus sign to make sources consistent with usual sign convention

        %evaluation at centroid points for finite difference
        dg12dx2_centroid = dg12dx2_centroid - term(centroid_xy(:,1),centroid_xy(:,2))*ds*dt;



         term = @(xo,yo)(2*(1 + u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^3)./ ...
     ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
          (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^2 -  ...
   ((3 - u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo))./ ...
     ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
        (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2) -  ...
   (2*(1 + u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo))./ ...
     ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
        (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2);

        %evaluate at observation coordinates
        dg22dx1 = dg22dx1 - term(obs_xy(:,1),obs_xy(:,2))*ds*dt ;  %minus sign to make sources consistent with usual sign convention

        %evaluation at centroid points for finite difference
        dg22dx1_centroid = dg22dx1_centroid - term(centroid_xy(:,1),centroid_xy(:,2))*ds*dt;



         term = @(xo,yo)(2*(1 + u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2.* ...
        (-((1 - s - t)*y1) - t*y2 - s*y3 + yo))./ ...
     ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
          (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^2 -  ...
   ((3 - u)*(-((1 - s - t)*y1) - t*y2 - s*y3 + yo))./ ...
     ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
        (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2);

        %evaluate at observation coordinates
        dg22dx2 = dg22dx2 - term(obs_xy(:,1),obs_xy(:,2))*ds*dt ;  %minus sign to make sources consistent with usual sign convention

        %evaluation at centroid points for finite difference
        dg22dx2_centroid = dg22dx2_centroid - term(centroid_xy(:,1),centroid_xy(:,2))*ds*dt;



         %strains

             term = -((8.*(1 + u).*(-((1 - s - t).*x1) - t.*x2 - s.*x3 + xo).^2.* ...
               (-((1 - s - t).*y1) - t.*y2 - s.*y3 + yo).^2)./ ...
            ((-((1 - s - t).*x1) - t.*x2 - s.*x3 + xo).^2 +  ...
                 (-((1 - s - t).*y1) - t.*y2 - s.*y3 + yo).^2).^3) +  ...
       (2.*(3 - u).*(-((1 - s - t).*x1) - t.*x2 - s.*x3 + xo).^2)./ ...
         ((-((1 - s - t).*x1) - t.*x2 - s.*x3 + xo).^2 +  ...
              (-((1 - s - t).*y1) - t.*y2 - s.*y3 + yo).^2).^2 +  ...
       (2.*(1 + u).*(-((1 - s - t).*y1) - t.*y2 - s.*y3 + yo).^2)./ ...
         ((-((1 - s - t).*x1) - t.*x2 - s.*x3 + xo).^2 +  ...
              (-((1 - s - t).*y1) - t.*y2 - s.*y3 + yo).^2).^2 -  ...
       (3 - u)./((-((1 - s - t).*x1) - t.*x2 - s.*x3 + xo).^2 +  ...
            (-((1 - s - t).*y1) - t.*y2 - s.*y3 + yo).^2);
    
    
        Ddg11dx1Dx = Ddg11dx1Dx - term*ds*dt ; 

       term = -((8*(1 + u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo).* ...
           (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^3)./ ...
        ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
             (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^3) +  ...
   (2*(3 - u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo).* ...
        (-((1 - s - t)*y1) - t*y2 - s*y3 + yo))./ ...
     ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
          (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^2 +  ...
   (4*(1 + u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo).* ...
        (-((1 - s - t)*y1) - t*y2 - s*y3 + yo))./ ...
     ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
          (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^2;

        Ddg11dx1Dy = Ddg11dx1Dy - term*ds*dt ; 
       


        term = -((8*(1 + u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo).* ...
           (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^3)./ ...
        ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
             (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^3) +  ...
   (2*(3 - u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo).* ...
        (-((1 - s - t)*y1) - t*y2 - s*y3 + yo))./ ...
     ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
          (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^2 +  ...
   (4*(1 + u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo).* ...
        (-((1 - s - t)*y1) - t*y2 - s*y3 + yo))./ ...
     ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
          (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^2;

        Ddg11dx2Dx = Ddg11dx2Dx - term*ds*dt ; 


        term = -((8*(1 + u)*(-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^4)./ ...
        ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
             (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^3) + ... 
   (2*(3 - u)*(-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2)./ ...
     ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
          (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^2 +  ...
   (10*(1 + u)*(-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2)./ ...
     ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
          (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^2 - ... 
   (3 - u)./((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
        (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2) -  ...
   (2*(1 + u))./((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 + ... 
        (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2);

        Ddg11dx2Dy = Ddg11dx2Dy - term*ds*dt ; 


        term = -((8*(-1 - u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^3.* ...
           (-((1 - s - t)*y1) - t*y2 - s*y3 + yo))./ ...
        ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
             (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^3) + ... 
   (6*(-1 - u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo).* ...
        (-((1 - s - t)*y1) - t*y2 - s*y3 + yo))./ ...
     ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
          (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^2;

          Ddg12dx1Dx = Ddg12dx1Dx - term*ds*dt ; 

          term = -((8*(-1 - u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2.* ...
           (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2)./ ...
        ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
             (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^3) +  ...
   (2*(-1 - u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2)./ ...
     ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
          (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^2 + ... 
   (2*(-1 - u)*(-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2)./ ...
     ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
          (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^2 - ... 
   (-1 - u)./((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
        (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2);

          Ddg12dx1Dy = Ddg12dx1Dy - term*ds*dt ; 


        term = -((8*(-1 - u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2.* ...
                   (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2)./ ...
                ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
                     (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^3) + ... 
           (2*(-1 - u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2)./ ...
             ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
                  (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^2 +  ...
           (2*(-1 - u)*(-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2)./ ...
             ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
                  (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^2 - ... 
           (-1 - u)./((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
                (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2);

          Ddg12dx2Dx = Ddg12dx2Dx - term*ds*dt ; 


            term = -((8*(-1 - u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo).* ...
           (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^3)./ ...
        ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
             (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^3) + ... 
   (6*(-1 - u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo).* ...
        (-((1 - s - t)*y1) - t*y2 - s*y3 + yo))./ ...
     ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
          (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^2;

          Ddg12dx2Dy = Ddg12dx2Dy - term*ds*dt ; 

          term = -((8*(1 + u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^4)./ ...
        ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
             (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^3) +  ...
   (2*(3 - u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2)./ ...
     ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
          (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^2 +  ...
   (10*(1 + u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2)./ ...
     ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
          (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^2 -  ...
   (3 - u)./((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
        (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2) -  ...
   (2*(1 + u))./((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
        (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2);

          Ddg22dx1Dx = Ddg22dx1Dx - term*ds*dt ;

        term = -((8*(1 + u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^3.* ...
           (-((1 - s - t)*y1) - t*y2 - s*y3 + yo))./ ...
        ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
             (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^3) +  ...
   (2*(3 - u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo).* ...
        (-((1 - s - t)*y1) - t*y2 - s*y3 + yo))./ ...
     ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
          (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^2 +  ...
   (4*(1 + u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo).* ...
        (-((1 - s - t)*y1) - t*y2 - s*y3 + yo))./ ...
     ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
          (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^2;

          Ddg22dx1Dy = Ddg22dx1Dy - term*ds*dt ;

        term = -((8*(1 + u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^3.* ...
           (-((1 - s - t)*y1) - t*y2 - s*y3 + yo))./ ...
        ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
             (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^3) + ... 
   (2*(3 - u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo).* ...
        (-((1 - s - t)*y1) - t*y2 - s*y3 + yo))./ ...
     ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
          (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^2 + ... 
   (4*(1 + u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo).* ...
        (-((1 - s - t)*y1) - t*y2 - s*y3 + yo))./ ...
     ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
          (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^2;

          Ddg22dx2Dx = Ddg22dx2Dx - term*ds*dt ;

            term = -((8*(1 + u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2.* ...
           (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2)./ ...
        ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
             (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^3) + ... 
   (2*(1 + u)*(-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2)./ ...
     ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
          (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^2 + ... 
   (2*(3 - u)*(-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2)./ ...
     ((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
          (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2).^2 -  ...
   (3 - u)./((-((1 - s - t)*x1) - t*x2 - s*x3 + xo).^2 +  ...
        (-((1 - s - t)*y1) - t*y2 - s*y3 + yo).^2);

          Ddg22dx2Dy = Ddg22dx2Dy - term*ds*dt ;

        

    end
end


%Strains at points within the triangle are poorly computed with the above
%integration scheme (not sure why). So, take finite difference at centroid
%and use for interior points

inside = find(inpolygon(obs_xy(:,1),obs_xy(:,2),nodes(:,1),nodes(:,2)));


%finite difference
Ddg11dx1Dx(inside) = (dg11dx1_centroid(1)-dg11dx1_centroid(2))/dx;
Ddg11dx2Dx(inside) = (dg11dx2_centroid(1)-dg11dx2_centroid(2))/dx;
Ddg12dx1Dx(inside) = (dg12dx1_centroid(1)-dg12dx1_centroid(2))/dx;
Ddg12dx2Dx(inside) = (dg12dx2_centroid(1)-dg12dx2_centroid(2))/dx;
Ddg22dx1Dx(inside) = (dg22dx1_centroid(1)-dg22dx1_centroid(2))/dx;
Ddg22dx2Dx(inside) = (dg22dx2_centroid(1)-dg22dx2_centroid(2))/dx;

Ddg11dx1Dy(inside) = (dg11dx1_centroid(3)-dg11dx1_centroid(4))/dy;
Ddg11dx2Dy(inside) = (dg11dx2_centroid(3)-dg11dx2_centroid(4))/dy;
Ddg12dx1Dy(inside) = (dg12dx1_centroid(3)-dg12dx1_centroid(4))/dy;
Ddg12dx2Dy(inside) = (dg12dx2_centroid(3)-dg12dx2_centroid(4))/dy;
Ddg22dx1Dy(inside) = (dg22dx1_centroid(3)-dg22dx1_centroid(4))/dy;
Ddg22dx2Dy(inside) = (dg22dx2_centroid(3)-dg22dx2_centroid(4))/dy;


dg21dx1 =  dg12dx1;
dg21dx2 =  dg12dx2;

Ddg21dx1Dx = Ddg12dx1Dx;
Ddg21dx1Dy = Ddg12dx1Dy;
Ddg21dx2Dx = Ddg12dx2Dx;
Ddg21dx2Dy = Ddg12dx2Dy;


%gij is displacement in i direction due to point force in j direction
u1.m11 = dg11dx1;
u1.m12 = dg11dx2;
u1.m21 = dg12dx1;
u1.m22 = dg12dx2;

u2.m11 = dg21dx1;
u2.m12 = dg21dx2;
u2.m21 = dg22dx1;
u2.m22 = dg22dx2;

e11.m11 = Ddg11dx1Dx;
e12.m11 = .5*(Ddg11dx1Dy + Ddg21dx1Dx);
e22.m11 = Ddg21dx1Dy;

e11.m12 = Ddg11dx2Dx;
e12.m12 = .5*(Ddg11dx2Dy + Ddg21dx2Dx);
e22.m12 = Ddg21dx2Dy;

e11.m21 = Ddg12dx1Dx;
e12.m21 = .5*(Ddg12dx1Dy + Ddg22dx1Dx);
e22.m21 = Ddg22dx1Dy;

e11.m22 = Ddg12dx2Dx;
e12.m22 = .5*(Ddg12dx2Dy + Ddg22dx2Dx);
e22.m22 = Ddg22dx2Dy;

