---
title: FRED
aliases:
  - Federal Reserve Economic Data
tags:
  - economics
  - data
  - forecasting
  - prediction-markets
  - api
  - research
---

# FRED

## Overview

**FRED (Federal Reserve Economic Data)** is a publicly available economic data platform maintained by the **Federal Reserve Bank of St. Louis**. It provides access to hundreds of thousands of time series from U.S. and international sources, making it one of the most widely used repositories for macroeconomic, financial, demographic, and monetary data.

FRED is designed to support economic research, policy analysis, financial modeling, forecasting, education, and data-driven decision making. Its standardized interface, extensive metadata, and free API make it a valuable resource for reproducible research workflows.

---

# What FRED Is

FRED serves as a centralized repository that aggregates data from numerous government agencies, central banks, statistical organizations, and international institutions.

Rather than generating data itself, FRED collects, standardizes, and distributes datasets from trusted primary sources.

Typical users include:

- economists
- financial analysts
- academic researchers
- data scientists
- quantitative traders
- policy analysts
- students
- journalists

---

# Available Datasets

FRED contains hundreds of thousands of economic time series spanning decades of historical observations.

Major categories include:

## National Accounts

- Gross Domestic Product (GDP)
- Gross National Product (GNP)
- Personal Income
- Personal Consumption
- Government Spending
- National Saving

---

## Inflation

- Consumer Price Index (CPI)
- Producer Price Index (PPI)
- Personal Consumption Expenditures (PCE)
- Core Inflation
- Inflation Expectations

---

## Employment

- Unemployment Rate
- Labor Force Participation
- Payroll Employment
- Job Openings
- Initial Jobless Claims
- Average Weekly Hours
- Wage Growth

---

## Interest Rates

- Federal Funds Rate
- Treasury Yields
- SOFR
- Mortgage Rates
- Commercial Paper Rates
- Corporate Bond Yields

---

## Monetary Data

- Money Supply (M1, M2)
- Bank Reserves
- Credit Measures
- Central Bank Balance Sheets
- Lending Activity

---

## Financial Markets

- Stock Market Indexes
- Exchange Rates
- Volatility Measures
- Credit Spreads
- Bond Indexes

---

## Housing

- Housing Starts
- Building Permits
- Home Prices
- Mortgage Applications
- Home Sales

---

## International Data

- Exchange Rates
- Inflation
- GDP
- Employment
- Trade Statistics
- Interest Rates

---

## Energy

- Oil Prices
- Natural Gas
- Electricity
- Renewable Energy
- Commodity Prices

---

## Demographics

- Population
- Birth Rates
- Death Rates
- Migration
- Educational Attainment

---

# API Overview

FRED provides a free REST API for programmatic access to its datasets.

Common capabilities include:

- searching for series
- downloading observations
- retrieving metadata
- filtering by date
- selecting output formats
- accessing historical revisions
- retrieving categories
- browsing releases
- obtaining source information

Supported formats commonly include:

- JSON
- XML

Typical workflow:

```text
Register API Key
        │
        ▼
Search Dataset
        │
        ▼
Retrieve Series
        │
        ▼
Filter Dates
        │
        ▼
Analyze Data
        │
        ▼
Visualize Results
        │
        ▼
Forecast
```

---

# Economic Indicators

Frequently used indicators include:

## Growth

- GDP
- Industrial Production
- Retail Sales
- Capacity Utilization

---

## Labor Market

- Unemployment Rate
- Payroll Employment
- Labor Force Participation
- Job Openings
- Weekly Claims

---

## Inflation

- CPI
- Core CPI
- PCE
- Core PCE
- Producer Prices

---

## Monetary Policy

- Federal Funds Rate
- Discount Rate
- Reserve Balances
- Money Supply

---

## Financial Conditions

- Treasury Yield Curve
- Corporate Bond Spreads
- Mortgage Rates
- Credit Conditions
- Financial Stress Indexes

---

## Housing Market

- Housing Starts
- Building Permits
- Existing Home Sales
- New Home Sales

---

## Consumer Activity

- Consumer Sentiment
- Personal Income
- Personal Spending
- Household Debt

---

# Data Quality

FRED emphasizes transparency and provenance.

Advantages include:

- documented data sources
- standardized formatting
- historical observations
- detailed metadata
- consistent identifiers
- revision tracking
- citation information

Researchers should still understand the methodology used by the original data provider.

---

# Update Frequency

Update frequency depends on the underlying dataset.

Common schedules include:

- daily
- weekly
- biweekly
- monthly
- quarterly
- annually

Examples:

| Indicator | Typical Frequency |
|------------|-------------------|
| Federal Funds Rate | Daily |
| Treasury Yields | Daily |
| Initial Jobless Claims | Weekly |
| CPI | Monthly |
| Payroll Employment | Monthly |
| GDP | Quarterly |
| Population Estimates | Annual |

Many series are revised after initial publication.

---

# Strengths

FRED offers several important advantages.

## Comprehensive Coverage

A large collection of economic and financial indicators from numerous trusted organizations.

---

## Standardized Access

Consistent interfaces simplify automation and reproducibility.

---

## Historical Depth

Many series extend back several decades, enabling long-term trend analysis.

---

## Revision History

Historical revisions support research into real-time forecasting and policy analysis.

---

## Free Access

Most datasets are freely available for research and educational purposes.

---

## Strong Metadata

Each series includes information about:

- source
- units
- frequency
- seasonal adjustment
- release information
- methodology

---

# Weaknesses

Despite its strengths, FRED has limitations.

## Publication Lag

Many indicators are published days or weeks after the underlying economic activity.

---

## Data Revisions

Initial releases are frequently revised.

Forecasting systems should account for revision risk.

---

## Limited Granularity

Some datasets provide only national aggregates rather than detailed regional or local information.

---

## Heterogeneous Sources

Because data originates from multiple agencies, methodologies and definitions can vary across series.

---

## Missing Context

Economic indicators often require domain expertise for proper interpretation.

---

# Applications to Prediction Markets

FRED data can improve research into prediction markets by providing objective macroeconomic context.

Potential applications include:

- evaluating economic event contracts
- modeling interest rate expectations
- studying recession probabilities
- analyzing inflation forecasts
- examining employment expectations
- comparing market prices with economic fundamentals

Example workflow:

```text
FRED Data
      │
      ▼
Feature Engineering
      │
      ▼
Prediction Market Data
      │
      ▼
Statistical Modeling
      │
      ▼
Probability Calibration
      │
      ▼
Forecast Evaluation
```

---

# Applications to Probabilistic Forecasting

Economic indicators provide valuable predictors for probabilistic models.

Possible use cases include:

- recession forecasting
- inflation forecasting
- unemployment prediction
- interest rate modeling
- credit risk estimation
- economic nowcasting
- Bayesian forecasting
- ensemble forecasting
- calibration studies

FRED can also be used to validate forecasting performance against observed outcomes.

---

# Future Integration Ideas

Potential integrations for this research project include:

## Automated Data Pipelines

- scheduled downloads
- incremental updates
- local caching
- metadata synchronization

---

## Forecast Dashboards

Combine FRED indicators with:

- prediction markets
- forecasting models
- Bayesian estimates
- machine learning predictions

---

## Feature Engineering

Generate derived variables such as:

- rolling averages
- growth rates
- moving volatility
- lagged indicators
- composite indexes
- standardized scores

---

## Reproducible Research

Integrate FRED with:

- Jupyter notebooks
- Python analysis pipelines
- version-controlled datasets
- experiment tracking
- automated reporting

---

## Knowledge Management

Link FRED-derived analyses directly into an Obsidian vault to maintain:

- research notes
- indicator documentation
- forecasting experiments
- literature reviews
- model evaluations

---

# Best Practices

- Document every series identifier used.
- Record data retrieval dates.
- Track data revisions when relevant.
- Preserve original units and transformations.
- Verify seasonal adjustment settings.
- Automate data downloads where possible.
- Store metadata alongside observations.
- Cite original data sources in publications.
- Validate preprocessing pipelines.
- Keep analysis reproducible through version control.

---

# Related Concepts

- Macroeconomics
- Monetary Policy
- Inflation
- Employment
- Economic Forecasting
- Time Series Analysis
- Bayesian Statistics
- Financial Markets
- Data Engineering
- Reproducible Research

---

# Suggested Internal Links

- [[Economic Indicators]]
- [[Macroeconomics]]
- [[Time Series Analysis]]
- [[Probabilistic Forecasting]]
- [[Prediction Markets]]
- [[Bayesian Statistics]]
- [[Machine Learning]]
- [[Data Analysis]]
- [[Research Workflow]]
- [[AI Research Workflow]]
- [[Reproducible Research]]
- [[Python]]
- [[Jupyter Notebooks]]
- [[Data Engineering]]
- [[Knowledge Management]]
- [[Obsidian]]
- [[Statistics]]
- [[Feature Engineering]]
- [[Documentation]]
- [[Version Control]]
```