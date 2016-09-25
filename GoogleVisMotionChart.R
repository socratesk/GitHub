####
# Precursor to this script is that the dataset is downloaded from Kaggle's competition website 
# "https://www.kaggle.com/c/bike-sharing-demand/data/" and saved locally in the following folder.
####

# Set working directory to load the data
setwd("C:/home/kaggle/BikeSharing")

# Install necessary packages
library(sqldf)
library(googleVis)

#Load dataset
train <- read.csv("train.csv", stringsAsFactors = FALSE)

# Filter dataset
filteredTrain <- train[, c("datetime", "casual", "registered")]

# Remove timestamp part and only Date
filteredTrain$date <- substr(filteredTrain$datetime, 1,10)

# Calculate SUM of Casual Users, Registered Users, and Total Users per day
filteredDF <- sqldf("select date, sum(casual) as casual, sum(registered) as registered 
                     from filteredTrain group by date")

# Convert Date field's data-type from 'Character' to 'Date'.
filteredDF$date <- as.Date(filteredDF$date)

# Melt dataframe to turn columns into rows, still keeping Date as column
fullDF <- melt(filteredDF, id='date')

# Change column name from 'variable' to 'type'
colnames(fullDF)[2] <- 'type'

# Change column name from 'values' to 'counts'
colnames(fullDF)[3] <- 'counts'

# Copy more columns for Motionchart
fullDF$period <- as.character(fullDF$date)
fullDF$user_type <- fullDF$type
fullDF$user_count <- fullDF$counts

# Reorder column names so that Motionchart picks-up automatically.
fullDF <- fullDF[, c("type", "date", "user_type", "period", "counts",  "user_count")]

# Convert 'period' column to numeric so that it is listed as one o fthe X-Axis variable.
fullDF$period <- as.numeric(strptime(fullDF$period, "%Y-%m-%d"))

# Create GoogleVis Motion Chart
M <- gvisMotionChart(fullDF, "type", "date", options = list(state=myStateSettings, width = 800, height = 600))

#Plot motion Chart on the browser. The chart will open in default browser window.
plot(M)

# After ensuring chart's behavior, save the main content of chart (not Head, Title, Body tags of HTML) in a file
print(M, 'chart', file="C:/Socrates-blog/assets/html/bikesharing.html")

# Open the saved file in Notepad, copy the content and paste it in your blog page (or in .MD file)
# Thats it. If you refresh the blog page, you should be able to see the motion chart embedded on the page.
