## goal: display C code underlying EasyABC::trait_model

pkg <- "EasyABC"
fn <- "trait_model"

t0 <- tempdir()
vv <- as.character(packageVersion(pkg))
tarball <- paste0(pkg,"_",vv,".tar.gz")
## download the source code
download.file(paste0("https://cran.r-project.org/src/contrib/",
                     tarball),destfile=file.path(t0,tarball))
## unpack it
untar(file.path(t0,tarball),exdir=t0)
## list source files (C/FORTRAN)
ff <- list.files(file.path(t0,pkg,"src"),full.names=TRUE)
## read text of source files into a list
rr <- lapply(ff,readLines)
## figure out which file has the function definition in it
w <- sapply(rr,function(x) length(grep(paste0(fn,"("),x,fixed=TRUE))>0)
## show it
file.show(ff[w])
