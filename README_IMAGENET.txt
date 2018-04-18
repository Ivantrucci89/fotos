This ZIP archive provides the files needed to import a Caffe model and
evaluate the model performance on a subset of the ImageNet data set.  The 
archive contains the following files:

- README_IMAGENET.TXT: this file
- score_imagenet_example.ipynb: evaluate performance of a number of
  predefined CNNs using a Jupyter notebook
- score_imagenet_example.sas: evaluate performance of a number of
  predefined CNNs using SAS code
- make_file_list.sh: creates a list of files and associated labels

We assume that the contents of this ZIP archive have been unpacked in
the directory $IMAGENET_EXAMPLE.  You will have to perform the following steps 
to run the example code:

1.) Create a root directory for the ImageNet images (referred to below as
    $IMAGE_ROOT)
    
2.) Download the file models.zip from the SAS support web site and unpack the
    contents in $IMAGENET_EXAMPLE.
    
3.) Choose one of the image classes included in the ImageNet classification challenge.  
    For example, “ladybug” is one of the 1000 classes.
    
4.) Go to the ImageNet download page (http://image-net.org/download-imageurls)
      a.) type ladybug in the Search box
      b.) you will get two hits.  Click on the link for Synset: ladybug, ladybeetle, lady beetle, ladybird, ladybird beetle.
      c.) click on the Download tab
      d.) click on the link for Download URLs of images in the synset
      e.) copy and paste the URLs to a text file.  Call this file ladybug_files.txt
      f.) copy ladybug_files.txt to $IMAGE_ROOT
      
5.) Create a directory to hold downloaded images.  Call it $IMAGE_ROOT/ladybug.

6.) Run the shell script make_file_list.sh with the following syntax
                $IMAGENET_EXAMPLE/make_file_list.sh $IMAGE_ROOT ladybug_files.txt ladybug          
    This script will download the images corresponding to the links that are not broken or defective.
    
7.) Download one of the SAS-provided CNN models from the SAS support web site and unpack the
    contents in $MODEL_ROOT (e.g. vgg16.zip).  Note that all CNN model archives contain the
    file newlabel.sas7bdat.  If you choose to download/unpack multiple CNN models, you may get
    a warning that newlabel.sas7bdat will be overwritten.  
    
You are now ready to run the example code.  If you prefer to use
Jupyter notebook, perform the following steps:    

1.) Start Jupyter notebook server from the $IMAGENET_EXAMPLE directory

2.) From the notebook dashboard, click on score_imagenet_example.ipynb 

3.) Edit the cell that begins with "# define variables used to control example"
    The in-line comments explain the variables and the settings you
    provide.
    
4.) Run all cells.

If you prefer to use SAS, perform the following steps:    

1.) Start your preferred SAS interface

2.) Navigate to the $IMAGENET_EXAMPLE directory and load score_imagenet_example.sas

3.) Edit the macro variables following the comment that begins with
   "set macro variables --> *MUST* be provided:"
    The in-line comments explain the variables and the settings you
    provide.
    
4.) Execute the code.

SAS Institute Inc., SAS Campus Drive, Cary, North Carolina 27513.

SAS® and all other SAS Institute Inc. product or service names are registered 
trademarks or trademarks of SAS Institute Inc. in the USA and other countries. 
® indicates USA registration.  Other brand and product names are registered trademarks 
or trademarks of their respective companies.

