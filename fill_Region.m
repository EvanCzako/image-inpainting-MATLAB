function filled = fill_Region(im,mask)

    % Returns a matrix/grayscale image corresponding to matrix/grayscale
    % image im with inward interpolation via LaPlace's equation applied to 
    % the pixels defined by logical matrix mask.
    %
    % This is essentially an extension of the algorithm described in the
    % following blog post by Steve Eddins of MathWorks: 
    % https://blogs.mathworks.com/steve/2015/06/17/region-filling-and-laplaces-equation/
    %
    % The only difference is that I have added the capability to apply the
    % algorithm to masked pixels at the edges or corners of the image. If a
    % masked pixel sits on the East edge of the image, for example,  
    % rather than the algorithm giving that pixel the average value of its
    % North, South, East, and West neighbors, it will give that pixel the
    % average value of its North, South, and West neighbors, for it has no
    % East neighbor. Similarly, a masked pixel in the SouthWest corner
    % of the image will take on the average value of its East and North
    % neighbors, for it has no South or West neighbors.
    %
    % To be clear, this function does not accomplish anything more than the
    % regionfill function of the Image Processing Toolbox. I just wanted to
    % complete the algorithm described by the above article to include
    % the edges and corners of images.
    %
    % Example:
    %     
    %     % Read in the image 'trees.tif'
    % 
    %     [X,map] = imread('trees.tif');
    %     I = im2double(ind2gray(X,map));
    %     figure, imagesc(I)
    % 
    %     % Add some holes to the image
    %     I(100:120,1:60) = nan;
    %     I(70:100,100:120) = nan;
    %     I(220:258,300:350) = nan;
    %     figure, imagesc(I)
    % 
    %     % Use fill_Region to fill in the holes
    %     mask = isnan(I);
    %     I_filled = fill_Region(I,mask);
    %     figure, imagesc(I_filled);
    %
    % 
    % Evan Czako, 8.26.2019
    % -------------------------------------------
    
    u = find(mask);
    w = find(~mask);
    M = size(mask,1);
    u_north = u - 1;
    u_north = (-double(mod(u_north,size(im,1))==0)+double(mod(u_north,size(im,1))~=0)).*u_north;
    u_east = u + M;
    u_east = (-double(u_east>size(im,1)*size(im,2)) + double(u_east<=size(im,1)*size(im,2))).*u_east;
    u_south = u + 1;
    u_south = (-double(mod(u_south,size(im,1))==1)+double(mod(u_south,size(im,1))~=1)).*u_south;
    u_west = u - M;

    a = [u_north u_east u_south u_west];
    b = double(a>0);
    c = -b./(sum(b')').*b;

    v = ones(size(u));
    ijv_mask = [...
        u  u         ones(length(u),1)
        u  u_north  c(:,1)
        u  u_east   c(:,2)
        u  u_south  c(:,3)
        u  u_west   c(:,4) ];

    bad_rows = [find(ijv_mask(:,2)<1); find(ijv_mask(:,2)>size(im,1)*size(im,2))];
    ijv_mask(bad_rows,:) = [];

    ijv_nonmask = [w  w  1.00*ones(size(w))];
    ijv = [ijv_mask; ijv_nonmask];
    A = sparse(ijv(:,1),ijv(:,2),ijv(:,3));
    b = im(:);
    b(mask(:)) = 0;

    x = A\b;
    filled = reshape(x,size(im));

end