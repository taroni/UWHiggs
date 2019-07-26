source preprocess_with_shapes.sh -analyzer EMAnalyzer -lumi 35862 -jobid fromNab -analtype cutBased -num_cat 3
source preprocess_with_shapes.sh -analyzer EMAnalyzer450 -lumi 35862 -jobid fromNab -analtype cutBased -num_cat 3
#source preprocess.sh -analyzer EMAnalyzer -lumi 35862 -jobid fromNab -analtype cutBased -num_cat 3
#source preprocess.sh -analyzer EMAnalyzer450 -lumi 35862 -jobid fromNab -analtype cutBased -num_cat 3

## make plots
source make_plots.sh -analyzer EMAnalyzer450 -lumi 35862  -analtype cutBased -num_cat 3 -signals 450,600,750,900
source make_plots.sh -analyzer EMAnalyzer -lumi 35862  -analtype cutBased -num_cat 3 -signals 200,300,450

