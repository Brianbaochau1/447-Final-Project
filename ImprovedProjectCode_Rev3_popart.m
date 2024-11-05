%%% Final Project - Revision 3 with Marilyn Monroe Pop-Art Effect %%%

%%% Load the Colored Image %%%
Image = imread("Specter.jpg");

%%% Define Pop-Art Colors for Foreground and Background %%%
popArtColors = {
    [255, 20, 147], [255, 255, 0];  % Pink foreground, yellow background
    [0, 255, 127], [0, 0, 255];     % Green foreground, blue background
    [255, 165, 0], [128, 0, 128];   % Orange foreground, purple background
    [75, 0, 130], [255, 182, 193]   % Indigo foreground, light pink background
};

% Initialize cell array to store the final pop-art images
popArtImages = cell(1, 4);

% Loop over each color pair to create a distinct pop-art variation
for i = 1:4
    % Step 1: Convert to grayscale for easier masking
    gray_Image = rgb2gray(Image);
    
    % Step 2: Create a binary mask for foreground (subject) and background
    mask = gray_Image > 120;  % Adjusted for improved subject-background separation
    
    % Step 3: Apply Foreground and Background Colors based on the mask
    foregroundColor = popArtColors{i, 1};
    backgroundColor = popArtColors{i, 2};
    
    % Initialize tinted image with background color
    tintedImg = uint8(ones(size(Image)) .* reshape(backgroundColor, 1, 1, 3));
    
    % Apply the foreground color to the subject area in each color channel
    for ch = 1:3
        channel = tintedImg(:, :, ch); % Extract each color channel
        channel(mask) = foregroundColor(ch); % Apply foreground color in masked area
        tintedImg(:, :, ch) = channel; % Update tinted image channel
    end
    
    %%% Improved Cartoonization Process for Tinted Image %%%
    
    % Step 4: Apply a Smoothing Filter -> Mild Gaussian Filter for slight blur
    smoothedImage = imgaussfilt(tintedImg, 0.2); % Mild smoothing

    % Step 5: Enhanced Edge Detection to Capture Detail -> Sobel filter
    % Using Sobel operator to get softer, yet visible edges
    edges = edge(rgb2gray(smoothedImage), 'Sobel');
    
    % Step 6: Reduce color quantization levels selectively
    numLevels = 45;  % Higher number for more detail preservation
    quantizedImg = round(double(smoothedImage) / 255 * (numLevels - 1)) * (255 / (numLevels - 1));
    quantizedImg = uint8(quantizedImg);

    % Step 7: Soft Edge Blending
    % Create a semi-transparent black overlay for edges to retain subtle details
    edgeOverlay = uint8(cat(3, ~edges, ~edges, ~edges) * 50); % Dark overlay
    detailedCartoonImg = min(quantizedImg + edgeOverlay, 255); % Blend edges with original

    % Store the pop-art style cartoonized image
    popArtImages{i} = detailedCartoonImg;
end

% Step 8: Create a 2x2 grid with the color-tinted cartoonized images
topRow = [popArtImages{1}, popArtImages{2}];
bottomRow = [popArtImages{3}, popArtImages{4}];
popArtGrid = [topRow; bottomRow];

% Step 9: Display and save the final pop-art cartoonized 2x2 image
figure;
imshow(popArtGrid);
title('Pop-Art Cartoonized Image with Enhanced Detail Preservation');

% Step 10: Save the final pop-art image
imwrite(popArtGrid, 'pop_art_cartoonized_detailed.jpg');
