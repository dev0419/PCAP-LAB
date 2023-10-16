#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION

#include <stdio.h>
#include <stdlib.h>
#include "stb_image/stb_image.h"
#include "stb_image/stb_image_write.h"

int main() {
    // Load the input image
    int width, height, channels;
    unsigned char* input_image = stbi_load("Lena.jpeg", &width, &height, &channels, 0);

    if (input_image == NULL) {
        printf("Failed to load the input image.\n");
        return 1;
    }

    // Create an output image of the same dimensions
    unsigned char* output_image = (unsigned char*)malloc(width * height * channels);

    // Embossing kernel
    int kernel[3][3] = {
        {-2, -1, 0},
        {-1,  1, 1},
        { 0,  1, 2}
    };

    // Apply embossing
    for (int y = 1; y < height - 1; y++) {
        for (int x = 1; x < width - 1; x++) {
            for (int c = 0; c < channels; c++) {
                int embossed_pixel = 0;
                for (int i = -1; i <= 1; i++) {
                    for (int j = -1; j <= 1; j++) {
                        int pixel_value = input_image[((y + i) * width + (x + j)) * channels + c];
                        embossed_pixel += pixel_value * kernel[i + 1][j + 1];
                    }
                }
                embossed_pixel = embossed_pixel > 255 ? 255 : (embossed_pixel < 0 ? 0 : embossed_pixel);
                output_image[(y * width + x) * channels + c] = embossed_pixel;
            }
        }
    }

    // Save the embossed image
    stbi_write_jpg("output_embossed.jpg", width, height, channels, output_image, 100);

    // Free memory
    stbi_image_free(input_image);
    free(output_image);

    return 0;
}
