%%% 447 Cartoonization Project - Mosaic Version - Revision 8 (11/14/2024)
%%% Using Morphology, Boundary Masking, and Watershed with Gradient

%% Load the image
Image = imread("avengers.jpg");

%%% Apply a Smoothing Filter -> Mean Filter %%%
avg_Filter = fspecial("average", [3 3]); % The right kernel size can assist in preserving important edges and removing noise early on
smootherImage = imfilter(Image, avg_Filter);

% Convert to Grayscale
gray_Image = rgb2gray(smootherImage);

% Apply a threshold
thresholdValue = 70; % Adjust this value as needed
binary_img = gray_Image > thresholdValue;

% Apply Morphological Dilation
se = strel('disk', 3); % Structuring element (disk shape with radius set to user's choice)
dilated_Image = imdilate(binary_img, se);

% Subtract the Original Image from the Dilated Image to Get the Exterior Boundary
exterior_boundary = dilated_Image - binary_img;

% Convert exterior_boundary to uint8 and scale to [0, 255]
exterior_boundary_uint8 = uint8(exterior_boundary * 255);

% Resize `exterior_boundary` to match the image size
[rows, cols, ~] = size(Image);
exterior_boundary_resized = imresize(exterior_boundary_uint8, [rows, cols]);

% Replicate `exterior_boundary_resized` across 3 channels to match original image
exterior_boundary_rgb = cat(3, exterior_boundary_resized, exterior_boundary_resized, exterior_boundary_resized);

% Initialize the result image by copying the original image
result_img = Image;

% Apply boundary masking: Set the boundary pixels to black (0, 0, 0) in the result image
% Create a mask for boundary pixels
boundary_mask = exterior_boundary_resized == 255;

% Set boundary pixels in all channels to black
for channel = 1:3
    result_img(:,:,channel) = result_img(:,:,channel);  % Get the current channel
    result_img(:,:,channel) = result_img(:,:,channel); % Apply to all channels

    result_img(boundary_mask) = 0;  % Set boundary pixels to black
end

% Display the result image after boundary subtraction
figure;
imshow(result_img, []);

%%% (Step 8) - Apply Color Quantization using Predefined Colors %%%
% Define an expanded basic color palette in RGB (avoiding gray, focusing on a variety of colors)
color_palette = [
    255, 0, 0;       % Red
    0, 255, 0;       % Green
    0, 0, 255;       % Blue
    255, 255, 0;     % Yellow
    0, 255, 255;     % Cyan
    255, 165, 0;     % Orange
    128, 0, 128;     % Purple
    0, 255, 127;     % Lime
    0, 128, 128;     % Teal
    255, 192, 203;   % Pink
    255, 215, 0;     % Gold
    34, 139, 34;     % Forest Green
    135, 206, 235;   % Sky Blue
    255, 99, 71;     % Tomato
    75, 0, 130;      % Indigo
    148, 0, 211;     % Dark Violet
    240, 230, 140;   % Khaki
    255, 255, 255;   % White
    0, 0, 0;         % Black
];

% Convert the palette to double for calculation
color_palette = double(color_palette);

% Get the dimensions of `result_img`
[rows, cols, channels] = size(result_img);
if channels ~= 3
    error('The image must have 3 color channels (RGB).');
end

% Reshape the `result_img` into a 2D array of RGB values
result_img_double = double(reshape(result_img, rows * cols, 3));

% Initialize a new array to store the quantized image
quantized_img = zeros(size(result_img_double));

% For each pixel, find the nearest color in the palette
for i = 1:size(result_img_double, 1)
    pixel = result_img_double(i, :);  % Current pixel RGB values

    % Calculate the Euclidean distance to each color in the palette
    distances = sum((color_palette - pixel) .^ 2, 2);
    
    % Find the index of the closest color
    [~, min_index] = min(distances);
    
    % Assign the closest color to the quantized image
    quantized_img(i, :) = color_palette(min_index, :);
end

% Reshape the quantized image back to the original dimensions
quantized_img = uint8(reshape(quantized_img, rows, cols, 3));

%%% (Step 9) - Apply Morphological Closing on Each Channel of Quantized Image %%%
% Structuring element for closing
se_close = strel('disk', 5); % Disk-shaped structuring element with radius 5

% Separate the quantized image into RGB channels
R = quantized_img(:,:,1);
G = quantized_img(:,:,2);
B = quantized_img(:,:,3);

% Apply morphological closing to each channel
R_closed = imclose(R, se_close);
G_closed = imclose(G, se_close);
B_closed = imclose(B, se_close);

% Combine the closed channels back into a single image
quantized_img_closed = cat(3, R_closed, G_closed, B_closed);

% Display the closed image
figure;
imshow(quantized_img_closed);
title('Image After Morphological Closing on Quantized Colors');

% Display the final image with watershed boundaries
figure;
imshow(result_with_watershed);
title('Image with Watershed Boundaries');

