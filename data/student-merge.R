d1=read.table("student-mat.csv",sep=";",header=TRUE)
d2=read.table("student-por.csv",sep=";",header=TRUE)

d3=merge(d1,d2,by=c("school","sex","age","address","famsize","pstatus","medu","fedu","mjob","fjob","reason","nursery","internet"))
print(nrow(d3)) # 382 students
