import cv2
import os
import imageio
import numpy as np
from os.path import join

in_lm_path = "./landmark"
in_or_path = "./origin"
out_lm_path = "./sized_landmark"
out_or_path = "./sized_origin"
combined_path = "./combined"

landmarks = os.listdir(in_lm_path)
origins = os.listdir(in_or_path)
assert(len(landmarks) <= len(origins))


def crop_and_resize(img, save_path):
    """ Crop the image to a 256*256 square"""

    # Crop the center 720*720 square
    crop_img = img[0:720, 280:1000]
    # Resize the image
    resized_img = cv2.resize(crop_img, (256, 256),
                             interpolation=cv2.INTER_AREA)
    # Save the image
    cv2.imwrite(save_path, resized_img)
    return resized_img


def combine_images(img1, img2, save_path):
    """ Horizontally combine two images side by side, then save to the path."""
    combined_img = np.concatenate((img1, img2), axis=1)
    cv2.imwrite(save_path, combined_img)


def make_gif(directory, save_path):
    """ Append all files in the directory to a gif file."""
    images = []
    with imageio.get_writer(save_path, mode='I') as writer:
        for f in sorted(os.listdir(directory)):
            print("\t" + f, end="\r")
            image = imageio.imread(join(directory, f))
            writer.append_data(image)

# Create output directories
if not os.path.exists(out_lm_path):
    os.makedirs(out_lm_path)
    os.makedirs(out_or_path)
    os.makedirs(combined_path)

for i in range(len(landmarks)):
    print("\t" + str(int(float(i) / len(landmarks))) + "% finished", end="\r")
    # Read images
    landmark_img = cv2.imread(join(in_lm_path, landmarks[i]))
    origin_img = cv2.imread(join(in_or_path, landmarks[i][:-6]+".png"))

    # Crop and save images
    img1 = crop_and_resize(landmark_img, join(out_lm_path, landmarks[i]))
    img2 = crop_and_resize(origin_img, join(out_or_path,
                                            landmarks[i][:-6]+".png"))

    # Combine the landmark and origin image side by side
    combine_images(img1, img2, join(combined_path, landmarks[i][:-6]+".png"))

make_gif("./combined", "./result.gif")
