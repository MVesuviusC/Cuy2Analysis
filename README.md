# Overview
This document summarizes the pipeline used to analyze the data presented in the paper "Dynamic microbial populations along the Cuyahoga River." by Cannon et al. The original analyses were done over a period of time and included portions of three separate pipelines run from three different directories. Additionally, the final portion of the analysis was run after the lab moved to UMB and the data was transferred, altering the directory structure. For these reasons the pipeline here should in no way be considered a �plug and play� pipeline, as the directory structure for different parts of the analysis will not match. I have maintained the directory structures as is (except the location of Perl scripts to allow for them to be included in the document) so as not to alter the analysis from its original form. The purpose of this document is not to provide a pipeline that can be run with no modifications but rather for two primary reasons. Firstly, this document provides the programs and options used in the analysis in a stepwise fashion. Secondly, all custom Perl code is included to allow for other researchers� use. If you plan on adapting this pipeline or Perl scripts to analyze your data, I would highly suggest that you review each step and all Perl code to be sure that it suits your purposes. A good familiarity with Unix and Perl is required for this. If you have questions on specific portions of the pipeline or need help analyzing your data feel free to contact me either through this GitHub repository or via email at matthewvc1@gmail.com and I will help if I can. 

Best regards,
Matt