/* This SAS code provides an example of importing a trained Caffe model and evaluating the performance of the model
   on a subset of the ImageNet data set.  The code below makes several assumptions:

  1.) The ImageNet example files obtained from the SAS support web site have been unpacked in the 
      directory $IMAGENET_EXAMPLE

  2.) You have already started a CAS server and you know the port number associated with that server

  3.) Your operating system is either Linux or Windows

  4.) You have obtained the model definition file models.zip from the SAS support web site and
      and unpacked the contents in the directory $IMAGENET_EXAMPLE 

  5.) You have obtained model parameter file(s) from the SAS support web site (e.g. vgg16.zip) and
      unpacked the contents in $MODEL_ROOT
 
  6.) You have a downloaded a subset of the ImageNet data set to $IMAGE_ROOT/$IMAGE_CLASS where $IMAGE_CLASS is
      one of the image classes defined by ImageNet.  This program uses $IMAGE_CLASS=ladybug.

  7.) Windows paths are specified in this form
           <drive letter>:\\directory1\\subdirectory1\\... (e.g. c:\\imagenet\\images)

  8.) Linux paths are specified in this form
            /directory1/subdirectory1/... (e.g. /imagenet/images)/* Import Caffe model and score MNIST test dataset */

/* used for loading model files on the SERVER */
%macro SetPathSeparator(os=LINUX);
    %global path_sep;
    %if (&os = LINUX) %then %do;
        %let path_sep=/;
    %end;
    %else %do;
        %let path_sep=\;
    %end;
%mend;

/* used for including model definitions on the CLIENT */
%macro SetModel(model=VGG16);
    %global model_file_name model_definition;

    %if (&SYSSCP = WIN) %then
        %let pd = \;
    %else
        %let pd = /;

    %if (&model = VGG16) %then %do;
        %let model_file_name=VGG_ILSVRC_16_layers;
        %let model_definition=&imagenet_example_path.&pd.model_vgg16.sas;
    %end;
    %else %if (&model = VGG19) %then %do;
        %let model_file_name=VGG_ILSVRC_19_layers;
        %let model_definition=&imagenet_example_path.&pd.model_vgg19.sas;
    %end;
    %else %if (&model = ResNet50) %then %do;
        %let model_file_name=ResNet-50-model;
        %let model_definition=&imagenet_example_path.&pd.model_resnet50.sas;
    %end;
    %else %if (&model = ResNet101) %then %do;
        %let model_file_name=ResNet-101-model;
        %let model_definition=&imagenet_example_path.&pd.model_resnet101.sas;
    %end;
    %else %if (&model = ResNet152) %then %do;
        %let model_file_name=ResNet-152-model;
        %let model_definition=&imagenet_example_path.&pd.model_resnet152.sas;
    %end;
%mend;

/* set macro variables --> *MUST* be provided:
    image_path = path to directory where ImageNet images are stored
    model_path = path to directory where converted Caffe model(s) are stored
    model_name = name of Caffe model file
    cashost = full name of CAS server host (e.g. cashost.xxx.yyy.zzz)
    port = port associated with CAS server (e.g. 12345)
    imagenet_example_path = path to directory where ImageNet example files are stored
    cas_server_os = CAS server operating system type (WINDOWS or LINUX) */

%let image_path= ;              /* $IMAGE_ROOT */
%let model_path= ;              /* $MODEL_ROOT */
%let model_name= ;              /* valid choices: ResNet50, ResNet101, ResNet152, VGG16, VGG19 */
%let cashost= ;
%let port= ;                    
%let imagenet_example_path= ;   /* $IMAGENET_EXAMPLE */
%let cas_server_os= ;           /* valid choices: WINDOWS or LINUX */

/* set OS-specific macro variables */
%SetPathSeparator(os=&cas_server_os);

/* specify model-related macro variables */
%SetModel(model=&model_name);

/* set SAS program to set image labels - match 50 character size of label table */
%let comp_pgm=_label_ %str(= %'ladybug                                           %';);

/* start cas session */
cas sascas1 host="&cashost" port=&port uuidmac=sascas1_uuid;
 
libname mycas sasioca host="&cashost" port=&port;
 
proc cas;

    /* load action sets */
    loadactionset 'tkdl';
    loadactionset 'image';

    ods exclude all;

    /* instantiate the model */
    %include "&model_definition";
 
    ods exclude none;

    /* load images */
    image.loadImages / casout={name='imagenet', replace=1} recurse=1 path="&image_path";
    run;

    /* resize images to 224 x 224 pixels */
    image.processImages / table={name="imagenet"} 
                          casout={name="imagenet_resize", replace=1}
                          imagefunctions={{functionoptions={functiontype='RESIZE',w=224, h=224}}}
    ;
    run;

    /* add library for Caffe models */
    table.addCaslib /
        dataSource={srcType="PATH"}
        name="modelhome"
        path="&model_path"
        activeOnAdd=FALSE
        session=false
        subDirectories=1
    ;
    run;

    /* load labels for output neurons:
        NOTE: neuron labels are 50 characters */
    table.loadTable / caslib='modelhome'
                  casout={caslib='CASUSER',name='imagenet_labels',replace=1}
                  importoptions={filetype='basesas'}
                  path='newlabel.sas7bdat'
    ;
    run;

    /* load weights from Caffe model */
    tkdl.dlImportModelWeights result=mw / model="&model_name"
                                modelWeights={name='tkdlWeights', replace=1}
                                labelTable={caslib='CASUSER',name='imagenet_labels',vars={'levid','levname'}},
                                formatType="CAFFE"
                                weightFilePath="&model_path.&path_sep.&model_file_name..caffemodel.h5"
    ;
    run;

    /* score with imported weights */
    tkdl.dlScore / table={name='imagenet_resize', compvars='_label_', comppgm="&comp_pgm"} model="&model_name" 
                   initWeights='tkdlWeights'
                   topProbs = 5
                   miniBatchSize = 3,
                   copyvars={'_label_'} casout='imported_score'
    ;
    run;

quit;

/* terminate session */ 
cas sascas1 terminate;
