library(dplyr)
library(tidyr)

# 1. Load the data into the workspace
# Descriptive info
features <- read.table(file = "UCI HAR Dataset/features.txt")
features <- as.character(features$V2)
select_features <- grep("mean|std", features)
selected_features <- features[select_features]
activities <- read.table("UCI HAR Dataset/activity_labels.txt")
activities <- tolower(as.character(activities$V2))

# Test data
y_test<- read.table(file = "UCI HAR Dataset/test/y_test.txt", col.names = "activity")
subject_test <- read.table(file = "UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
X_test <- read.table(file = "UCI HAR Dataset/test/X_test.txt") 

# Train data
y_train<- read.table(file = "UCI HAR Dataset/train/y_train.txt", col.names = "activity")
subject_train <- read.table(file = "UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
X_train <- read.table(file = "UCI HAR Dataset/train/X_train.txt")


# 2. Varibales are selected and renamed
# Select only variables which are means or standard deviations
test_data <- as_tibble(X_test) %>% select(all_of(select_features))
train_data <- as_tibble(X_train) %>% select(all_of(select_features))

# Rename variables
names(test_data) <- selected_features
names(train_data) <- selected_features

# 3
# Bind data together
test_data <- bind_cols(y_test, subject_test, test_data)
train_data <- bind_cols(y_train, subject_train, train_data)
tidy_data <- bind_rows("train" = train_data, "test" = test_data, .id = "set") %>%
    mutate(activity = as.factor(activities[activity]), subject = as.factor(subject))

# 4
# Create summary data
summary <- group_by(tidy_data, activity, subject) %>% summarise_at(vars(-group_cols(), -set), mean)

# 5
# Write data to .csv files
write.table(tidy_data, file = "tidy_data.txt", row.name = FALSE)
write.table(summary, file = "summary.txt", row.name = FALSE)