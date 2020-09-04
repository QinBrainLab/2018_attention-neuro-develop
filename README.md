# 2018_attention-neuro-develop

Summary and Requirements:
-------------------------------
This repository contains Matlab, Python and R scripts needed to produce key results found in manuscript. 

Test Environment(s):
----------------------
- MATLAB Version: 9.1.0.441655 (R2016b)
- Python Version: 3.7.6
- R Version: 3.6.3
- Operating System: Microsoft Windows 10 Professional Edition

Behavior Analyses (Figure_1):
-------------------------------
- Calculation of behavior indicators: behav_calcu.m
- Make figure for comparison between groups: fig1_bar_cohort1.R, fig1_bar_cohort2.R
- Make figure for GAM fitting: fig1_gam.R

Maturation Index Analyses (Figure_2):
-----------------------------------------
- Calculation of maturation index: rsa_multi2one.m
- Make figure for GAM fitting: fig2_gam.R

Neural Specialization Analyses (Figure_3):
-------------------------------
- Extracting parameter estimates (or beta weights): extr_beta.m
- Present the results of functional dissociation: fig3_polar.ipynb
- Make bar graphs of activation intensity: fig3_bar_children.R, fig3_bar_adults.R

Neural Pattern Stability Analyses (Figure_4):
-------------------------------
- Calculation of multivariate pattern similarity: rsa_sim.m
- Make bar graphs of neural pattern stability: fig4_bar_children.R, fig4_bar_adults.R

Neural Generalization Analyses (Figure_5):
-------------------------------
- Calculation of generalizability: general_calcu.m (require the CANLAB core tools, https://github.com/canlab/CanlabCore)
- Significance statistics and presentation of results: fig5_general.ipynb
