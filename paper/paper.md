---
title: "JMDSFCv1.0: an Interactive R/Shiny Application for Dataset Format Conversion with Real-Time Progress Monitoring"
authors:
  - name: January G. Msemakweli
    orcid: 0009-0007-6743-8479
    affiliation: 1
  - name: Khalid Juma Mzuka
    orcid: 
    affiliation: 1
affiliations:
  - name: Muhimbili University of Health and Allied Sciences, School of Public Health and Social Sciences, Department of Environmental and Occupational Health
    index: 1
corresponding:
  name: January G. Msemakweli
  email: msemakwelijanuary@gmail.com
bibliography: paper.bib
repository: https://github.com/january-msemakweli/JMDSFCv1.0
---

# Summary

In modern data analysis, working with diverse dataset formats is essential for ensuring compatibility across different software tools and platforms. However, manual conversion between formats can be time-consuming and error-prone. To address this challenge, we developed an interactive Shiny application, **JMDSFCv1.0**, that facilitates seamless conversion of datasets between popular software formats such as CSV, Excel, SAS, SPSS, Stata, and RData.

The app enables users to upload datasets, select an output format, and download the converted file with a single click. It also features a real-time progress indicator, enhancing the user experience by showing conversion progress. Built with simplicity and efficiency in mind, **JMDSFCv1.0** is designed for researchers, data analysts, and practitioners who regularly handle multiple file formats in their workflows. The app's intuitive interface and clear guidance make it accessible even to users with minimal technical background.

# Statement of Need

The increasing diversity of data formats used across various fields, such as data science, research, and industry, pose significant challenges for interoperability and seamless data analysis. Analysts often work with datasets in different formats, including CSV, Excel, SAS, SPSS, Stata, and RData. Manual conversion methods are often tedious, error-prone, and time-consuming, especially when data integrity is critical. Additionally, some formats require specialized software knowledge, which limits accessibility for individuals without the technical expertise.

**JMDSFCv1.0** was developed as a user-friendly solution that automates dataset format conversion. This app is especially beneficial for researchers, data analysts, and practitioners who handle diverse datasets, providing a streamlined, efficient, and reliable tool to facilitate smooth data interoperability.

# Key Features

1. **User Interface Design**: The app provides a clean and simple interface, allowing users to upload datasets in various formats (e.g., CSV, Excel, SAS, SPSS, Stata, RData), select the output format from a dropdown, and convert the dataset with a single click.
2. **File Format Support**: The app supports a wide range of data formats, including CSV, Excel (.xlsx), SAS (.sas7bdat), SPSS (.sav), Stata (.dta), and RData (.rdata/.RDATA).
3. **Real-Time Progress Indicator**: The app features a progress bar that updates in real-time during the conversion process, providing users with feedback on the conversion's progress.
4. **Automated Conversion Logic**: The app automatically handles the conversion process using appropriate R libraries (e.g., `readr` for CSV, `readxl` for Excel, `haven` for SAS, SPSS, and Stata, and native R functions for RData).
5. **Download Feature**: After conversion, users can download the newly formatted file directly from the app.

# Software and Implementation

**JMDSFCv1.0** is developed using the R Shiny framework. The core functionality is driven by automated conversion logic utilizing several R libraries (`readr`, `readxl`, `haven`). The app also features a download button that appears only when the conversion is complete, ensuring a smooth and transparent user experience.

# Acknowledgments

None.

# Funding

This research received no external funding.

# Conflicts of Interest

The authors declare no conflict of interest.

# Data Availability

Data sharing is not applicable to this article as no new data were created in this study.

# Author Contributions

- J.M. and K.M.: Conceptualization, Investigation, Project administration, Validation, Coding and Visualization, Writing – original draft, Writing – review & editing.
