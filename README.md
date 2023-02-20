# Exploratory Data Analysis and Visualization for Human Resources dataset

The main purpose of this analysis is to display the main characteristics of the organization, find the most significant determinants of a salary, as well as gain information about the most successful employees. The analysis is conucted in R.

## Dataset description

The original dataset from Kaggle (https://www.kaggle.com/datasets/rhuebner/human-resources-data-set) contained 311 observations of employees from a certain organization and 36 variables. We conducted data transformations and feature engineering, and our final dataset consisted of 294 observations and 47 variables.

## Data visualisation

### Organization distribution

![Mock Slide](https://github.com/karolinaszczesna/data-visualisation/blob/5ab5c12dd47a7f6e83455bf419e11140bab68eb4/plots/s2.png)

The donut chart shows that there are more females in the organization than males. When it comes to race, the majority of employees are of white race, then there are significant shares of employees of black or asian race (pie chart). Based on the horizontal barplot, there is an equal number of widowed females and males in the organization. Moreover, the number of separated females highly exceeds the number of separated males, whereas the differences in other marital statuses are less varied. Stacked barplot indicates that employees of white, black or asian races work in all departments of the organization, while indian/native or other races work in sales or production and all hispanic people are employed in the production sector. 

###  Salary distribution with respect to departments

![Mock Slide](https://github.com/karolinaszczesna/data-visualisation/blob/d7c63cf29c76fbd0de90933af6fe2680ed4faccc/plots/s3.png)

Histograms and density plots in the upper part show that all distributions are right-skewed. The boxplots and violin plots indicate that employees from Engineering and IT departments have the highest median of salary compared to Sales and Production. Other than that, violin plots show that there are a lot of extreme observations in the IT department and one or two outliers in Production or Sales - these are the managers who earn much more than other employees.

### Department salary between-subject comparisons

![Mock Slide](https://github.com/karolinaszczesna/data-visualisation/blob/1c563b7050bbb364a04c8e2e3e70b70d5825182c/plots/s10.png)

XXX

### How the number of years worked impact the salary in each department?

![Mock Slide](https://github.com/karolinaszczesna/data-visualisation/blob/1c563b7050bbb364a04c8e2e3e70b70d5825182c/plots/s4.png)

From these four bubble plots it is clearly visible that in Production department, there is almost no variety in earned salary based on work experience. In order to better compare all employees, an interactive bubble plot was created.

![Mock Slide](https://github.com/karolinaszczesna/data-visualisation/blob/4a4cd3803734b07a451eb32a58166e8e22b255d4/gifs/S5.gif)

This aggregated interactive plot made with plotly library combines bubble plots presented before for all departments but Production. Similar conclusions can be drawn in Sales, where the only observation with a yearly salary above $150k is a Sales Manager and all other employees earn below $100k a year. The employees from the Engineering department also do not earn more as their work experience grows, however the average salary oscillates around $100k a year, which is higher than in Production and Sales. There is an increasing trend in the IT/IS department, meaning the more years an employee works, probably the higher he/she can earn, however only for the best performing employees. There is a group of IT employees, who work from 6-8 years and are stuck on the same level of yearly salary.

####  S6
![Mock Slide](https://github.com/karolinaszczesna/data-visualisation/blob/1c563b7050bbb364a04c8e2e3e70b70d5825182c/plots/s6.png)

####  S7
![Mock Slide](https://github.com/karolinaszczesna/data-visualisation/blob/1c563b7050bbb364a04c8e2e3e70b70d5825182c/plots/s7.png)

####  S8
![Mock Slide](https://github.com/karolinaszczesna/data-visualisation/blob/1c563b7050bbb364a04c8e2e3e70b70d5825182c/plots/s8.png)

####  S9
![Mock Slide](https://github.com/karolinaszczesna/data-visualisation/blob/1c563b7050bbb364a04c8e2e3e70b70d5825182c/plots/s9.png)

####  S10
![Mock Slide](https://github.com/karolinaszczesna/data-visualisation/blob/2177a742f15b524b6ec6856b39d7320b5e755d22/gifs/gganim_yearOfHire.gif)

####  Map 1 Interactive
![Mock Slide](https://github.com/karolinaszczesna/data-visualisation/blob/0ef4b4444abb2a73947c7d0548f61276851f241b/maps/map1.gif)

####  Map 2 Interactive
![Mock Slide](https://github.com/karolinaszczesna/data-visualisation/blob/0ef4b4444abb2a73947c7d0548f61276851f241b/maps/map2.gif)

