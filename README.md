# JMDSFCv1.0: Dataset Format Converter

## Overview

**JMDSFCv1.0** is a user-friendly Shiny application designed to convert datasets between various popular formats, such as CSV, Excel, SAS, SPSS, Stata, and RData. The app simplifies the process of dataset conversion with a real-time progress indicator and a download feature to retrieve the converted dataset.

## Features

- Supports conversion between popular dataset formats: 
  - CSV (`.csv`)
  - Excel (`.xlsx`)
  - SAS (`.sas7bdat`)
  - SPSS (`.sav`)
  - Stata (`.dta`)
  - RData (`.rdata`, `.RDATA`)
- Real-time progress indicator to show the conversion progress.
- Preview the uploaded dataset before conversion.
- Simple and intuitive interface.
- Download button appears only after successful conversion.

## Getting Started

### Prerequisites

Before running the app, ensure you have the following packages installed in your R environment:

install.packages(c("shiny", "shinyjs", "foreign", "readr", "readxl", "haven", "DT", "progress"))

### Installation

Clone this repository to your local machine:

git clone https://github.com/yourusername/JMDSFCv1.0.git

Open the R project or R script containing the Shiny app code.

Run the app using RStudio or any R console:

shiny::runApp("path_to_your_app_directory")

## Usage

1. Upload a dataset file in one of the supported formats (CSV, Excel, SAS, SPSS, Stata, RData).
2. Select the output format from the dropdown menu.
3. Click the **Convert Dataset** button to initiate the conversion process.
4. Monitor the real-time progress through the displayed progress indicator.
5. Once the conversion is complete, a **Download Converted Dataset** button will appear.
6. Click the button to download the converted file in the selected format.

## Screenshots

![App Interface](https://github.com/january-msemakweli/JMDSFCv1.0-Dataset-Format-Converter/blob/main/Figures/JMDSFCv1.0%20UI.png)

## Built With

- [Shiny](https://shiny.rstudio.com/)
- [shinyjs](https://deanattali.com/shinyjs/)
- [foreign](https://cran.r-project.org/web/packages/foreign/index.html)
- [readr](https://readr.tidyverse.org/)
- [readxl](https://readxl.tidyverse.org/)
- [haven](https://haven.tidyverse.org/)
- [DT](https://rstudio.github.io/DT/)

## Author

Developed by **January G. Msemakweli**  and **Khalid Mzuka**
Email: msemakwelijanuary@gmail.com 
LinkedIn: [Your LinkedIn Profile](https://linkedin.com/in/january-msemakweli)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

None.

## Funding

This research received no external funding.

## Conflicts of Interest

The author declares no conflict of interest.

## Ethics Statement

Not applicable.

## Data Availability

Data sharing is not applicable to this project as no new data were created.
