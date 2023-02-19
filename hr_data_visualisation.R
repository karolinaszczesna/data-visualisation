######################################################
#                  Human Resources                   #
#                EDA & Visualisation                 #
#                                                    #
#                   Mateusz Cedro                    #
#                 Karolina Szczęsna                  #
######################################################

library(readr)
library(tidyverse)
library(ggthemes)
library(ggplot2)
library(viridis)
library(hrbrthemes)
library(gridExtra)
library(grid)
library(eeptools)
library(lubridate)
library(anytime)
library(ymd)
#install.packages('ggalt')
library(ggalt)
#install.packages("ggridges")
library(ggridges)

#install.packages("remotes")
#remotes::install_github("R-CoderDotCom/ridgeline@main")
library(ridgeline)
library(highcharter)
library(scales)
library(ggstatsplot)
library(leaflet)
library(gifski)
library(png)
library(gapminder)
library(gganimate)
options(scipen=10000)

df <- read_csv("/Users/karolina.szczesna/Desktop/HRDataset_v14.csv")
zip  <- read_csv("/Users/karolina.szczesna/Desktop/zip_lat_long.csv")

######################################################
#                  Data Dictionary                   #
######################################################

# https://rpubs.com/rhuebner/hrd_cb_v14

# Employee_Name	                Employee’s full name	Text
# EmpID	                        Employee ID is unique to each employee	Text
# MarriedID	                    Is the person married (1 or 0 for yes or no)	Binary
# MaritalStatusID	              Marital status code that matches the text field MaritalDesc	Integer
# EmpStatusID	                  Employment status code that matches text field EmploymentStatus	Integer
# DeptID	                      Department ID code that matches the department the employee works in	Integer
# PerfScoreID	                  Performance Score code that matches the employee’s most recent performance score	Integer
# FromDiversityJobFairID	      Was the employee sourced from the Diversity job fair? 1 or 0 for yes or no	Binary
# Salary	                      The person’s yearly salary. $ U.S. Dollars	Float
# Termd	                        Has this employee been terminated - 1 or 0	Binary
# PositionID	                  An integer indicating the person’s position	Integer
# Position	                    The text name/title of the position the person has	Text
# State	                        The state that the person lives in	Text
# Zip	                          The zip code for the employee	Text
# DOB	                          Date of Birth for the employee	Date
# Sex	                          Sex - M or F	Text
# MaritalDesc	                  The marital status of the person (divorced, single, widowed, separated, etc)	Text
# CitizenDesc	                  Label for whether the person is a Citizen or Eligible NonCitizen	Text
# HispanicLatino	              Yes or No field for whether the employee is Hispanic/Latino	Text
# RaceDesc	                    Description/text of the race the person identifies with	Text
# DateofHire	                  Date the person was hired	Date
# DateofTermination	            Date the person was terminated, only populated if, in fact, Termd = 1	Date
# TermReason	                  A text reason / description for why the person was terminated	Text
# EmploymentStatus	            A description/category of the person’s employment status. Anyone currently working full time = Active	Text
# Department	                  Name of the department that the person works in	Text
# ManagerName	                  The name of the person’s immediate manager	Text
# ManagerID	                    A unique identifier for each manager.	Integer
# RecruitmentSource	            The name of the recruitment source where the employee was recruited from	Text
# PerformanceScore	            Performance Score text/category (Fully Meets, Partially Meets, PIP, Exceeds)	Text
# EngagementSurvey	            Results from the last engagement survey, managed by our external partner	Float
# EmpSatisfaction	              A basic satisfaction score between 1 and 5, as reported on a recent employee satisfaction survey	Integer
# SpecialProjectsCount	        The number of special projects that the employee worked on during the last 6 months	Integer
# LastPerformanceReviewDate	    The most recent date of the person’s last performance review.	Date
# DaysLateLast30	              The number of times that the employee was late to work during the last 30 days	Integer
# Absences	                    The number of times the employee was absent from work.	Integer

######################################################
#               Data Transformations                 #
######################################################

df %>% 
  select(Department) %>% 
  group_by(Department) %>% 
  summarise(count=n())

# Department                count

# 1 Admin Offices            9
# 2 Executive Office         1
# 3 IT/IS                   50
# 4 Production             209
# 5 Sales                   31
# 6 Software Engineering    11

# We have decided to exclude from our dataset "Executive Office" and "Admin Offices"
# because there were very few observations of those two subgrups - 1 and 9 respectively

dfAdm <- df %>% 
  select_all() %>% 
  filter(Department != "Executive Office", Department != "Admin Offices")

df_final <- merge(dfAdm, zip, by.x = "Zip", by.y = "ZIP")

######################################################
#               Feature Engineering                  #
######################################################

# age
# convert date of birth string to dates
DOB <- df_final$DOB
DOB <- as.Date(DOB, format = "%m/%d/%Y")
DOB <- gsub("00", "19", DOB)
DOB <- ymd(DOB)

# current date
date_today <- Sys.Date()

# convert birth to age
Age <- age_calc(DOB,          
                date_today,
                units = "years")
# round age
Age <- floor(Age)  

# add age column to dataframe
df_final <- df_final %>% 
  mutate(Age)

# years worked
# convert date of birth string to dates
df_final$DOH <- df_final$DateofHire
df_final$DOH <- as.Date(df_final$DOH, format = "%m/%d/%Y")
df_final$DOH <- ymd(df_final$DOH)

# convert date of termination string to dates
df_final$DOT <- df_final$DateofTermination
df_final$DOT <- as.Date(df_final$DOT, format = "%m/%d/%Y")
df_final$DOT <- ymd(df_final$DOT)

# add "Is working?" column to dataframe based on date of termination
df_final$DOT <- !is.na(df_final$DOT)
df_final$IsWorking <- df_final$DOT

# add years worked column to dataframe
for (i in 1:nrow(df_final)) {
  if (df_final$DOT[[i]] == FALSE) {
    df_final$YearsWorked[[i]] <- difftime(date_today, df_final$DOH[i])/365
  } else {
    df_final$YearsWorked[[i]] <- difftime(as.Date(df_final$DateofTermination[i], format = "%m/%d/%Y"), df_final$DOH[i])/365
  }
}

# change the types of variables
df_final$YearsWorked <- as.numeric(df_final$YearsWorked)
df_final$EmpSatisfaction <- as.factor(df_final$EmpSatisfaction)
df_final$MaritalStatusID <- as.factor(df_final$MaritalStatusID)
df_final$MarriedID <- as.factor(df_final$MarriedID)
df_final$DaysLateLast30 <- as.factor(df_final$DaysLateLast30)

# add Salary (in k$) column to dataframe
df_final <- df_final %>% 
  mutate(SalaryK = Salary/1000)
df_final$SalaryK <- round(df_final$SalaryK, 2)

# add day of hire column to dataframe
df_final$DayOfHire <- format(as.Date(df_final$DOH,format="%Y-%m-%d"), format = "%d")
df_final$DayOfHire <- as.numeric(df_final$DayOfHire)

# add years of hire column to dataframe
df_final$YearOfHire <- format(as.Date(df_final$DOH,format="%Y-%m-%d"), format = "%Y")
df_final$YearOfHire <- as.numeric(df_final$YearOfHire)

# rename "Software Engineering" department as "Engineering"
df_final <- df_final %>% 
  mutate(Department = str_replace(Department, "Software Engineering", "Engineering"))

# renaming observations in race column
df_final <- df_final %>% 
  mutate(RaceDesc = str_replace(RaceDesc, "American Indian or Alaska Native", "Indian/Native")) %>%
  mutate(RaceDesc = str_replace(RaceDesc, "Black or African American", "Black")) %>%
  mutate(RaceDesc = str_replace(RaceDesc, "Two or more races", "More races"))

######################################################
#                    PLOTS                           #
######################################################

# donut theme
donut_theme <-
  theme(panel.background = element_rect(fill = "white"),
        panel.grid = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank()) +
  theme(plot.title = element_text(color="black", size=17)) +
  theme(legend.title = element_text(size = 14, family = "sans", colour = "gray48")) +
  theme(legend.text = element_text(size = 12, family = "sans", colour = "gray48"))

# Plot Slide 2
# plot 1
# sex diversity - donut chart
hsize <- 1.5

df_sex <- df_final %>%
  group_by(Sex) %>%
  summarize(count = n()) %>%
  mutate(freq=round(count*100/sum(count), 0)) %>%
  mutate(x = hsize)
head(df_sex)

p1 <- ggplot(df_sex, aes(x = hsize, y = freq, fill = Sex)) +
  geom_col(color = "gray48") +
  coord_polar(theta = "y") +
  scale_fill_manual(values=c("#FDE725FF", "#29AF7FFF")) +
  xlim(c(0.2, hsize + 0.5)) +
  labs(title="Distribution of Sex") + donut_theme +
  geom_text(aes(y = freq/2 + c(cumsum(freq/1.15)[-length(freq)], cumsum(freq/30)[-length(freq)]),
                label = percent(freq/100)),  size=4)
p1

# plot 2
# race - donut chart
library(ggrepel)

df_race <- df_final %>%
  group_by(RaceDesc) %>%
  summarize(count = n()) %>%
  mutate(freq=round(count*100/sum(count), 1)) %>%
  mutate(x = hsize)

df_race <- df_race %>%
  rename("Race" = "RaceDesc")

df_race <- df_race %>% 
  mutate(csum = rev(cumsum(rev(count))), 
         pos = count/2 + lead(csum, 1),
         pos = if_else(is.na(pos), count/2, pos))

p2 <- ggplot(df_race, aes(x = hsize, y = count, fill =fct_inorder(Race))) +
  geom_col(width = 1, color = "gray48") +
  coord_polar(theta = "y") +
  scale_fill_viridis_d() + 
  scale_color_viridis_d() +
  labs(title = "Distribution of Race") +
  donut_theme +
  geom_label_repel(data = df_race,
                   aes(y = pos, label = paste0(freq, "%")),
                   color = c("white","white","white",1,1,1),
                   size = 4, nudge_x = 1, show.legend = F,segment.color=1) +
  guides(fill = guide_legend(title = "Race"))
p2

# plot 3
# marital status vs gender
df_final %>% 
  group_by(MaritalDesc, Sex) %>% 
  summarise(N = n()) %>%
  mutate(freq=round(N*100/sum(N), 0)) %>%
  mutate(MaritalDesc = factor(MaritalDesc)) %>%
  mutate(Sex = factor(Sex)) %>%
  arrange(desc(N)) -> df_marital

p3 <- ggplot(data = df_marital, aes(x = MaritalDesc, y = freq,  fill = Sex)) +
  geom_bar(na.rm = TRUE, position = position_dodge(), width = 0.7, stat = "identity", color = "grey48") +
  labs(title = "Distribution of Marital Status",
       subtitle = "with respect to gender",
       y = "", x = "") +
  coord_flip() +
  scale_fill_manual(values=c("#FDE725FF", "#29AF7FFF")) +
  theme_gdocs() +
  theme(plot.title = element_text(color="black", size=17)) 
p3

# plot 4
# race vs department
df_final %>% 
  group_by(RaceDesc, Department) %>% 
  summarise(N = n()) %>%
  mutate(freq=round(N*100/sum(N), 0)) %>%
  mutate(RaceDesc = factor(RaceDesc)) %>%
  mutate(Department= factor(Department)) %>%
  arrange(desc(N)) -> df_race2

df_race2 <- df_race2 %>%
  rename("Race" = "RaceDesc")

p4 <- ggplot(data = df_race2, aes(x = Race, y = freq,  fill = Department)) +
  geom_bar(na.rm = TRUE, position = "fill", width = 0.7, stat = "identity", color = "gray48") +
  labs(title = "Distribution of race",
       subtitle = "with respect to department",
       y = "", x = "") +
  coord_flip() +
  theme_gdocs() +
  theme(plot.title = element_text(color="black", size=17)) +
  scale_fill_viridis_d() + scale_color_viridis_d()
p4

library(Rmisc)
s2 <- multiplot(p1, p3, p2, p4, cols = 2)
s2

# Plot Slide 3
# density plot
fig1 <-ggplot(df_final, aes(x=SalaryK, fill=Department)) +
  geom_density(alpha = 0.7) +
  scale_y_continuous(breaks = seq(0, 0.00006, by = 0.00001)) +
  labs(title = "Salary density",
       subtitle = "with respect to Department",
       y = "Density", x = "Salary (in k)") +
  theme_gdocs() +
  scale_fill_viridis_d() + scale_color_viridis_d() +
  scale_x_continuous(labels = dollar) +
  theme(axis.text.y = element_blank(),
        legend.position = "none",
        plot.title = element_text(color="black", size=17))
fig1

# box plot
df_box <- df_final %>%
  mutate(Department = fct_reorder(Department, desc(Salary)))

fig2 <-ggplot(df_box, aes(x=SalaryK, y=Department, fill=Department)) +
  geom_boxplot() +
  labs(title = "Salary density",
       subtitle = "with respect to Department",
       y = "", x = "Salary (in k)") +
  theme_gdocs() +
  scale_fill_manual(values=c("#440154FF", "#2D708EFF","#FDE725FF", "#55C667FF")) +
  scale_x_continuous(labels = dollar) +
  theme(legend.position = "none",
        plot.title = element_text(color="black", size=17))
fig2

# violin plot
fig3 <-ggplot(df_box, aes(x=SalaryK, y=Department, fill=Department)) +
  geom_violin() +
  labs(title = "Salary density",
       subtitle = "with respect to Department",
       y = "", x = "Salary (in k)") +
  theme_gdocs() +
  scale_fill_manual(values=c("#440154FF", "#2D708EFF","#FDE725FF", "#55C667FF")) +
  scale_x_continuous(labels = dollar) +
  theme(legend.position = "none",
        plot.title = element_text(color="black", size=17))
fig3

# histogram facet_wrap()
fig4 <-ggplot(df_final, aes(x=SalaryK, fill=Department)) +
  geom_histogram() +
  labs(title = "Salary distribution",
       subtitle = "with respect to Department",
       y = "Count", x = "Salary (in k)") +
  theme_gdocs() +
  scale_fill_viridis_d() + scale_color_viridis_d() +
  scale_x_continuous(labels = dollar) +
  facet_wrap(~Department, scales="free_y") +
  theme(axis.text.y = element_blank(),
        legend.position = "none",
        plot.title = element_text(color="black", size=17))
fig4

library(Rmisc)
s3 <- multiplot(fig4, fig2, fig1, fig3, cols = 2)
s3

# Plot Slide 4
# IT/IS
df_it <- df_final %>%
  group_by(Department) %>%
  filter(Department=="IT/IS") %>%
  mutate(SalaryK=round(Salary/1000, 2))

g1 <- ggplot(data = df_it, aes(x=YearsWorked, y=SalaryK, size = Age)) +
  geom_point(alpha=0.5, color = "#1F968BFF") +
  scale_size(range = c(2, 10), name="Age") +
  scale_y_continuous(labels = dollar, limits =c(50,250)) +
  scale_x_continuous(limits = c(0,15)) +
  labs(title = "Years worked vs Salary in IT/IS",
       subtitle = "with respect to age",
       y = "Salary (in k)", x = "Years Worked") +
  theme_gdocs() +
  theme(plot.title = element_text(color="black", size=17))
g1

# Sales
df_sales <- df_final %>%
  group_by(Department) %>%
  filter(Department=="Sales") %>%
  mutate(SalaryK=round(Salary/1000, 2))

g2 <- ggplot(data = df_sales, aes(x=YearsWorked, y=SalaryK, size = Age)) +
  geom_point(alpha=0.5, color = "#FDE725FF") +
  scale_size(range = c(2, 10), name="Age") +
  scale_y_continuous(labels = dollar, limits =c(50,250)) +
  scale_x_continuous(limits = c(0,15)) +
  labs(title = "Years worked vs Salary in Sales",
       subtitle = "with respect to age",
       y = "Salary (in k)", x = "Years Worked") +
  theme_gdocs() +
  theme(plot.title = element_text(color="black", size=17)) 
g2

# Engineering
df_eng <- df_final %>%
  group_by(Department) %>%
  filter(Department=="Engineering") %>%
  mutate(SalaryK=round(Salary/1000, 2))

g3 <- ggplot(data = df_eng, aes(x=YearsWorked, y=SalaryK, size = Age)) +
  geom_point(alpha=0.5, color = "#440154FF") +
  scale_size(range = c(2, 10), name="Age") +
  scale_y_continuous(labels = dollar, limits =c(50,250)) +
  scale_x_continuous(limits = c(0,15)) +
  labs(title = "Years worked vs Salary in Engineering",
       subtitle = "with respect to age",
       y = "Salary (in k)", x = "Years Worked") +
  theme_gdocs() +
  theme(plot.title = element_text(color="black", size=17)) 
g3

# Production
df_prod <- df_final %>%
  group_by(Department) %>%
  filter(Department=="Production") %>%
  mutate(SalaryK=round(Salary/1000, 2))

g4 <- ggplot(data = df_prod, aes(x=YearsWorked, y=SalaryK, size = Age)) +
  geom_point(alpha=0.5, color = "#55C667FF") +
  scale_size(range = c(2, 10), name="Age") +
  scale_y_continuous(labels = dollar, limits =c(50,250)) +
  scale_x_continuous(limits = c(0,15)) +
  labs(title = "Years worked vs Salary in Production",
       subtitle = "with respect to age",
       y = "Salary (in k)", x = "Years Worked") +
  theme_gdocs() +
  theme(plot.title = element_text(color="black", size=17)) 
g4

library(Rmisc)
s4 <- multiplot(g1, g3, g2, g4, cols = 2)
s4

# Plot Slide 5
library(ggplot2)
library(plotly)

grouped_df3 <- subset(df_final, Department!="Production")

grouped_df3$YearsWorked <- round(grouped_df3$YearsWorked, 1)

length(grouped_df3$Employee_Name)

s5 <- grouped_df3 %>%
  ggplot(aes(YearsWorked, SalaryK, color = Department)) +
  geom_point(size = 4, alpha=0.5) +
  scale_y_continuous(labels = dollar, limits =c(50,250)) +
  labs(title = "Years worked vs Salary",
       y = "Salary (in k)", x = "Years Worked") +
  scale_color_viridis_d() +
  theme_gdocs() +
  theme(plot.title = element_text(color="black", size=17))

ggplotly(s5)

# Plot Slide 6
library(ggalluvial)

df_final$Married <- df_final$MarriedID

df_alluv <- df_final %>%
  group_by(PerformanceScore, IsWorking, Sex, Married) %>%
  summarize(count = n()) %>%
  mutate(freq=round(count*100/sum(count), 0)) %>%
  mutate(PerformanceScore = str_replace(PerformanceScore, "Needs Improvement", "Below Average")) %>%
  mutate(PerformanceScore = str_replace(PerformanceScore, "PIP", "Below Average")) %>%
  mutate(PerformanceScore = str_replace(PerformanceScore, "Fully Meets", "Above Average")) %>%
  mutate(PerformanceScore = str_replace(PerformanceScore, "Exceeds", "Above Average")) %>%
  mutate(Married = str_replace(Married, "0", "Single")) %>%
  mutate(Married = str_replace(Married, "1", "Married"))

s6 <- ggplot(data = df_alluv,
             aes(axis1 = PerformanceScore, axis2 = Sex, axis3 = Married, y = freq)) +
  scale_x_discrete(limits = c("Performance", "Gender", "Marital Status"), expand = c(.2, .05)) +
  xlab("") +
  ylab("") +
  geom_alluvium(aes(fill = IsWorking)) +
  geom_stratum() +
  geom_text(stat = "stratum", aes(label = after_stat(stratum))) +
  theme_gdocs() +
  theme(plot.title = element_text(color="black", size=17)) +
  scale_fill_manual(values=c("#20A387FF", "#33638DFF")) +
  theme(axis.text.y = element_blank()) +
  ggtitle("Employees of the organization",
          "stratified by performance and demographics")
s6

# Plot Slide 7
s7 <- ggplot(df_final, aes(x=YearsWorked, y=SalaryK)) + 
  geom_point(shape=20, size = 2.5, color = '#33638DFF') + 
  geom_smooth(method = "loess", level = 0.45, color = '#440154FF') +
  labs(title="Salary on Years Worked")+
  theme_gdocs() +
  theme(plot.title = element_text(color="black", size=17)) +
  scale_fill_viridis() + scale_colour_viridis()+
  scale_y_continuous(labels = dollar, limits =c(50,250)) +
  labs(x = "Years Worked", y = "Salary (in k)")
s7


# Plot Slide 8
s8 <- ggplot(df_final, aes(x=YearsWorked, y=SalaryK, color=Department, fill=Department)) + 
  geom_point(shape=20, size = 2.5) + 
  geom_smooth(method = "loess", se=T, level = 0.15,) +
  theme_bw() + 
  geom_encircle(aes(x=YearsWorked, y=SalaryK,
                    group=Department,), 
                alpha = 0.65,
                data=subset(df_final, SalaryK > 125), 
                size=2.5,
                s_shape=0.5,
                expand=0.01) +
  labs(title="Salary on Years Worked",
       subtitle = "with respect to department")+
  scale_fill_viridis_d() + scale_colour_viridis_d()+
  theme_gdocs() +
  theme(plot.title = element_text(color="black", size=17)) +
  scale_y_continuous(labels = dollar, limits =c(50,250)) +
  labs(x = "Years Worked", y = "Salary (in k)")
s8


# Plot Slide 9
s9 <- ggplot(df_final, aes(x=YearsWorked, y=SalaryK, color=RecruitmentSource,
                           fill=RecruitmentSource)) + 
  geom_point(shape=20, size = 2.5) + 
  geom_smooth(method = "glm", se=T, level = 0.2) +
  geom_encircle(aes(x=YearsWorked, y=SalaryK,
                    group=RecruitmentSource), 
                alpha = 0.65,
                data=subset(df_final, SalaryK > 125), 
                size=2.5,
                s_shape=0.5,
                expand=0.03) +   # encircle
  labs(title="Salary on Years Worked",
       subtitle = "with respect to recruitment score")+
  scale_fill_viridis_d() + scale_colour_viridis_d() +
  theme_gdocs()  +
  theme(plot.title = element_text(color="black", size=17)) +
  scale_y_continuous(labels = dollar, limits =c(50,250)) +
  labs(x = "Years Worked", y = "Salary (in k)")
s9


# Plot Slide 10
set.seed(123)
s10 <- ggbetweenstats(
  df_final,
  x = Department,
  y = SalaryK,
  nboot = 10,
  messages = TRUE,
  pairwise.display = "significant",
  point.args = list(alpha = 1, size=4,
                    position = ggplot2::position_jitterdodge(dodge.width = 0.8)))

s10 + scale_colour_viridis_d() +
  labs(title="Department Salary Between-Subjects Comparisons") +
  theme_gdocs() +
  labs(y = "Salary (in k)") +
  theme(plot.title = element_text(color="black", size=17)) +
  scale_y_continuous(labels = dollar, limits =c(50,250))

# Plot Slide 11
s11_df <- df_final %>% 
  select(YearOfHire, Department,SalaryK) %>% 
  group_by(YearOfHire, Department) %>% 
  summarise(NumOfHired = n(), meanSalaryK = round(mean(SalaryK),2))

s11 <- ggplot(s11_df, aes(YearOfHire, NumOfHired,color = Department)) +
  geom_line(size = 0.75) +
  labs(x = "Year of Hire", y = "Number of Employees",
       title = "Number of Employments in Department per year",
       caption = "Frame {frame} of {nframes}") + 
  theme(legend.position = "top") +
  scale_x_continuous(breaks=seq(2006,2018,4)) + 
  scale_colour_viridis_d()+
  theme_gdocs()+ theme(plot.title = element_text(color="black", size=17)) +
  geom_point(aes(group = seq_along(Department))) + scale_y_continuous()

s11 <- s11 + geom_point(aes(size = meanSalaryK))
s11 <- s11 + transition_reveal(YearOfHire)
s11
animate(s11, nframes = 75, renderer = gifski_renderer("gganim_yearOfHire.gif"))

colors_pal <- c('#55C667FF', '#2D708EFF', '#440154FF', '#FDE725FF')
labels_pal <- c('Production', 'IT/IS', 'Engineering','Sales')

# Plot Slide 12
leaflet() %>%
  addProviderTiles(providers$CartoDB.PositronNoLabels) %>%
  setView(lat=36, lng=-90 , zoom=3.5) %>%
  addCircleMarkers(data = df_final[df_final$Department == 'Production', ],
                   lng = ~LNG,
                   lat = ~LAT,
                   radius = 5,
                   fillColor = F,
                   color = '#55C667FF',
                   fillOpacity = T,
                   popup = ~Department,
                   group = 'Production') %>%
  addCircleMarkers(data = df_final[df_final$Department == 'IT/IS', ],
                   lng = ~LNG,
                   lat = ~LAT,
                   radius = 5,
                   fillColor = F,
                   color = '#2D708EFF',
                   fillOpacity = T,
                   popup = ~Department,
                   group = 'IT/IS') %>%
  addCircleMarkers(data = df_final[df_final$Department == 'Engineering', ],
                   lng = ~LNG,
                   lat = ~LAT,
                   radius = 5,
                   fillColor = F,
                   color = '#440154FF',
                   fillOpacity = T,
                   popup = ~Department,
                   group = 'Engineering') %>%
  addCircleMarkers(data = df_final[df_final$Department == 'Sales', ],
                   lng = ~LNG,
                   lat = ~LAT,
                   radius = 5,
                   fillColor = F,
                   color = '#FDE725FF',
                   fillOpacity = T,
                   popup = ~Department,
                   group = 'Sales') %>%
  addTiles(group="Political") %>%
  addProviderTiles(providers$Esri.WorldImagery,
                   group="Geographical") %>%
  addLegend(values = ~Department, colors = colors_pal, labels = labels_pal,
            position = "topright", opacity = 1) %>%
  addLayersControl(baseGroups=c("Political", "Geographical"),
                   overlayGroups = c('Production', 'IT/IS', 'Engineering', 'Sales'),
                   options = layersControlOptions(collapsed = FALSE),
                   position = 'topright')

# Plot Slide 13
leaflet() %>%
  addProviderTiles(providers$CartoDB.VoyagerLabelsUnder) %>%
  setView(lat=42, lng=-71 , zoom=7) %>%
  addCircleMarkers(data = df_final[df_final$Department == 'Production', ],
                   lng = ~LNG,
                   lat = ~LAT,
                   radius = 5,
                   fillColor = F,
                   color = '#55C667FF',
                   fillOpacity = T,
                   popup = ~Department,
                   group = 'Production') %>%
  addCircleMarkers(data = df_final[df_final$Department == 'IT/IS', ],
                   lng = ~LNG,
                   lat = ~LAT,
                   radius = 5,
                   fillColor = F,
                   color = '#2D708EFF',
                   fillOpacity = T,
                   popup = ~Department,
                   group = 'IT/IS') %>%
  addCircleMarkers(data = df_final[df_final$Department == 'Engineering', ],
                   lng = ~LNG,
                   lat = ~LAT,
                   radius = 5,
                   fillColor = F,
                   color = '#440154FF',
                   fillOpacity = T,
                   popup = ~Department,
                   group = 'Software Engineering') %>%
  addCircleMarkers(data = df_final[df_final$Department == 'Sales', ],
                   lng = ~LNG,
                   lat = ~LAT,
                   radius = 5,
                   fillColor = F,
                   color = '#FDE725FF',
                   fillOpacity = T,
                   popup = ~Department,
                   group = 'Sales') %>%
  addTiles(group="Political") %>%
  addProviderTiles(providers$Esri.WorldImagery,
                   group="Geographical") %>%
  addLegend(values = ~Department, colors = colors_pal, labels = labels_pal,
            position = "topright", opacity = 1) %>%
  addLayersControl(baseGroups=c("Political", "Geographical"),
                   overlayGroups = c('Production', 'IT/IS', 'Engineering', 'Sales'),
                   options = layersControlOptions(collapsed = FALSE),
                   position = 'topright')

group = "circles"



