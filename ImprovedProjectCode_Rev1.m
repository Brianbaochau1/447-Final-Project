% Step 1: Load the colored image
img = imread('IMG_0975.jpg'); 

% Step 2: Smooth the colored image using a bilateral filter
% NeighborhoodSize must be <= 200 and DegreeOfSmoothing controls the range of intensity smoothing
%smoothedImg = imbilatfilt(img, 15, 25);  % Adjusted for strong but valid smoothing

%mean filter to smooth out image instead
H = fspecial('average', [10 10]);
smoothedImg1 = imfilter(img, H);
%imshow(smoothedImg1); title("Using the mean filter");

% Step 3: Convert the smoothed image to grayscale for edge detection
grayImg = rgb2gray(smoothedImg1);

% Step 4: Apply edge detection using the Laplacian method
% Create a Laplacian filter with default settings
laplacianFilter = fspecial('laplacian', 0.2);  % Parameter controls the Laplacian filter shape
edges = imfilter(grayImg, laplacianFilter, 'replicate');  % Apply the Laplacian filter

% Step 5: Apply a median filter to reduce noise in the edge-detected image
% Use a 3x3 or 5x5 neighborhood to reduce noise while preserving edges
edges = medfilt2(edges, [3 3]);  % 5x5 median filter to smooth out the noise
edges = medfilt2(edges, [3 3]);  % 5x5 median filter to smooth out the noise

% Binarize the edge image to get clean edges (threshold manually or use `imbinarize`)
edges = imbinarize(edges);  % Convert the edges to a binary image

% Step 6: Reduce the color variations (color quantization / posterization)
% Quantize each color channel of the smoothed image to reduce color variations
numLevels = 6;  % Number of color levels to keep, adjust for desired effect (fewer levels = more cartoonish)

% Apply quantization to each color channel (R, G, B)
% Divide the pixel values into 'numLevels' levels and then map them back
quantizedImg = round(double(smoothedImg1) / 255 * (numLevels - 1)) * (255 / (numLevels - 1));
quantizedImg = uint8(quantizedImg);  % Convert back to uint8

% Step 7: Smooth the quantized image (Post-Quantization Smoothing)
% You can use a bilateral filter again to maintain edges or Gaussian filter for more general smoothing
% Bilateral filter for edge-preserving smoothness
smoothedQuantizedImg = imbilatfilt(quantizedImg, 15, 25);  % Additional smoothing after quantization

% Step 8: Create a black edge overlay
% Convert the logical edge image to a 3-channel black image
edgeOverlay = zeros(size(img), 'uint8');  
edgeOverlay(repmat(edges, [1, 1, 3])) = 0;  % Set edges to black

% Step 9: Set detected edges to black by applying them on the smoothed quantized image
cartoonizedImg = smoothedQuantizedImg;  % Start with the smoothed quantized image
cartoonizedImg(repmat(edges, [1, 1, 3])) = 0;  % Overlay black edges explicitly

% Step 10: Display the original and cartoonized images
figure;
subplot(1, 2, 1); imshow(img); title('Original Image');
subplot(1, 2, 2); imshow(cartoonizedImg); title('Cartoonized Image with Smoothed Edges and Reduced Noise');

% Step 11: Save the cartoonized image
imwrite(cartoonizedImg, 'cartoonized_image_with_smoothed_edges.jpg');


