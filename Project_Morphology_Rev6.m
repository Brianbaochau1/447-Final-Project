%%% 447 Cartoonization Project - Revision 6 (11/14/2024)
%%% Using Morphology instead

%% Load the image
Image = imread("avengers.jpg");

%%% Apply a Smoothing Filter -> Mean Filter %%%
avg_Filter = fspecial("average", [3 3]); %the right kernel size can assist in preserving important edges and removing noise early on
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

% Replicate `exterior_boundary` across 3 channels to match original image
exterior_boundary_rgb = cat(3, exterior_boundary_uint8, exterior_boundary_uint8, exterior_boundary_uint8);

% Subtract exterior_boundary_rgb from Original Image
result_img = imsubtract(Image, exterior_boundary_rgb);

figure;
imshow(result_img, []);

%%% (Step 8) - Apply Color Quantization using Predefined Colors %%%
% Define the basic color palette in RGB (customize these colors as needed)
color_palette = [
    255, 0, 0;     % Red
    0, 255, 0;     % Green
    0, 0, 255;     % Blue
    255, 255, 0;   % Yellow
    0, 255, 255;   % Cyan
    255, 0, 255;   % Magenta
    255, 255, 255; % White
    0, 0, 0        % Black
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

%%% (Step 9) - Display the Quantized Image %%%
figure;
imshow(quantized_img);
title('Image with Limited Color Variation');