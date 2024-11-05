%%% Final Project - Revision 2

%%% Load the Colored image first %%%
Image = imread("IMG_0975.jpg");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Attempted Test Cases changing Average, Laplacian, and Median Flter
%%% parameters Using my blurry selfie named "IMG_0975", "C_logo_number2", and
%%% "andrewgarfield"

%average filter [3 3] -> Noisy
% " " [5 5] -> Less Noisy
%Laplacian at 0.6 and Average filter [3 3] -> More Noise came back
%Avg [5 5] and L 0.6 -> Good but still some noise here and there 
%Avg [5 5], L 0.6, and first median filter to [5 5] and second median to [3 3]
%Avg [5 5], L 0.6, and first median filter to [3 3] and second median to [5 5]
%Avg [3 3], L 0.6, and first median filter to [3 3] and second median to [5 5]

%Best Test case (for blurry/noisy photos):
%Avg [5 5], L 0.6, and first median filter to [5 5] and second median to [5 5]

%but this wasn't good for pictures without noise. The average filter was
%too much on these good pictures and we lost helpful details. Here's the
%test case that may work best for both:

%Best Test case (for both blurry photos and less blurry ones)
%Avg [3 3], L 0.4, and first median filter to [5 5] and second median to [5 5]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% (Step 1) - Apply a Smoothing Filter -> Mean Filter %%%
avg_Filter = fspecial("average", [3 3]); %the right kernel size can assist in preserving important edges and removing noise early on
smootherImage = imfilter(Image, avg_Filter);

%%% (Step 2) - Convert the smoothened image to Grayscale %%%
gray_Image = rgb2gray(smootherImage);

%%% (Step 3) - Edge Detection Filter to Preserve Edges -> Laplacian %%%
LaplacianFilter = fspecial('laplacian', 0.4);  % Parameter controls the Laplacian filter shape
edges = imfilter(gray_Image, LaplacianFilter, 'replicate');  % Apply the Laplacian filter

%%% (Step 4) - Reduce noise -> Median Filter (Twice) %%%
edges1 = medfilt2(edges, [5 5]);  % 5x5 median filter to smooth out the noise
edges2 = medfilt2(edges1, [5 5]);  % 5x5 median filter to smooth out the noise AGAIN

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% (I haven't edited the lines below yet, still need to look at them)%%%

% Binarize the edge image to get clean edges (threshold manually or use `imbinarize`)
clean_Edges = imbinarize(edges2);  % Convert the edges to a binary image

% Step 6: Reduce the color variations (color quantization / posterization)
% Quantize each color channel of the smoothed image to reduce color variations
numLevels = 6;  % Number of color levels to keep, adjust for desired effect (fewer levels = more cartoonish)

% Apply quantization to each color channel (R, G, B)
% Divide the pixel values into 'numLevels' levels and then map them back
quantizedImg = round(double(smootherImage) / 255 * (numLevels - 1)) * (255 / (numLevels - 1));
quantizedImg = uint8(quantizedImg);  % Convert back to uint8

% Step 7: Smooth the quantized image (Post-Quantization Smoothing)
% You can use a bilateral filter again to maintain edges or Gaussian filter for more general smoothing
% Bilateral filter for edge-preserving smoothness
smoothedQuantizedImg = imbilatfilt(quantizedImg, 15, 25);  % Additional smoothing after quantization

% Step 8: Create a black edge overlay
% Convert the logical edge image to a 3-channel black image
edgeOverlay = zeros(size(Image), 'uint8');  
edgeOverlay(repmat(clean_Edges, [1, 1, 3])) = 0;  % Set edges to black

% Step 9: Set detected edges to black by applying them on the smoothed quantized image
cartoonizedImg = smoothedQuantizedImg;  % Start with the smoothed quantized image
cartoonizedImg(repmat(clean_Edges, [1, 1, 3])) = 0;  % Overlay black edges explicitly

% Step 10: Display the original and cartoonized images
figure;
subplot(1, 2, 1); imshow(Image); title('Original Image');
subplot(1, 2, 2); imshow(cartoonizedImg); title('Cartoonized Image with Smoothed Edges and Reduced Noise');

% Step 11: Save the cartoonized image
imwrite(cartoonizedImg, 'cartoonized_image_with_smoothed_edges.jpg');
