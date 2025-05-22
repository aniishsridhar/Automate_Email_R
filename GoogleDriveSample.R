library("googledrive")
drive_auth()
googlepath = "70-208 Regression F22 Attendance"
localpath = "Documents"

drive_mkdir(googlepath)

#######################$Get-Data###################################

files <- drive_ls(path = googlepath) 
num_files = nrow(files)
counter = 1
for (i in num_files-1:num_files+1){
  drive_download(files$name[i], path = files$name[i] ,type="csv", overwrite=TRUE)
}
##################################################################
filename_vec = tail(c(files$name),2)
df_sunday = read.csv(file_name[2])
df_tuesday = read.csv(filename_vec[1])
df_sunday['Andrew.ID'] = paste(df_sunday$Andrew.ID,"@andrew.cmu.edu", sep="")
df_tuesday['Andrew.ID'] = paste(df_tuesday$Andrew.ID,"@andrew.cmu.edu", sep="")

df_combine = data.frame(df_sunday$Name, df_sunday$Andrew.ID)
df_combine['Sunday-Attendance'] = df_sunday$Attendance
df_combine['Tuesday-Attendance'] = df_tuesday$Attendance
df_combine['Week_Total'] = df_combine['Sunday-Attendance'] + df_combine['Tuesday-Attendance']
df_combine[is.na(df_combine)] <- 0
absentees = subset(df_combine, Week_Total <2)

absentee_andrew = unique(absentees$df_sunday.Andrew.ID)
absentee_name = unique(absentees$df_sunday.Name)

#################################################


library(gmailr)
gm_auth_configure(path = "cronjson.json")
gm_auth(cache = ".secret")


for (i in 1:length(absentee_andrew)){
coursenumber = "70208"
text_msg <- gm_mime() %>%
  gm_to("aniishs@andrew.cmu.edu") %>%
  gm_from("aniishs@andrew.cmu.edu") %>%
  gm_subject(paste0(coursenumber, "- Absence"))%>%
gm_text_body(paste0("Hello ", absentee_name[i],
"
Greetings and good afternoon.
It seems that you missed at least one class of ", coursenumber, " this week. Please remember that you are allowed three free absences after which you will lose 0.5% for every absence. Please do not hesitate to contact the TA, CA or Professor if you have concerns about the same.",

          
"
Thanks & regards,
" ))
gm_send_message(text_msg)}


###################################################################

file  <- 
  drive_upload("70208Sample.csv",
    name = "sample2.csv",
    overwrite = TRUE,  path = googlepath, type="spreadsheet"
  )

email_list = c("aniish.sridhar@gmail.com", "aniishs@andrew.cmu.edu")


for (val in email_list){

  file <- file %>%
  drive_share(
    role = "writer",
    type = "user",
    emailAddress =val,
    emailMessage = paste0("This is the attendance record for", Sys.Date())
  )}

#################################################################