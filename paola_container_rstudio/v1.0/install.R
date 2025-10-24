library(remotes)

bioc_repos <- c(
  "https" = "https://cran.r-project.org",
  "bioc" = "https://bioconductor.org/packages/3.19/bioc",
  "annotation" = "https://bioconductor.org/packages/3.19/data/annotation",
  "experiment" = "https://bioconductor.org/packages/3.19/data/experiment"
)

split_string <- function(input_string) {
  # Split the string based on the version symbols
  parts <- strsplit(input_string, "==|<=|>=|<|>")[[1]]
  
  # Find the symbol used in the input string
  symbol <- regmatches(input_string, regexpr("==|<=|>=|<|>", input_string))
  
  # Return the parts and the symbol
  list(pkg_name = parts[1], version = paste(symbol, parts[2], sep = " "))
}


# Read list of packages from requirements.txt
pkgs <- readLines("requirements.txt")

message("Found ", length(pkgs), " packages to install")

# Install packages getting version string where present in the format "package version"
for (pkg in pkgs) {
	source <- "CRAN"
	pkg_name <- pkg
	pkg <- strsplit(pkg, "\\+")[[1]]
	if (length(pkg) == 2) { 
		source <- pkg[1] 
		pkg_name <- pkg[2]
	}

	if (source == "git") {
		message("Installing package ", pkg_name, " from ", source)
		remotes::install_github(pkg_name)
		next
	}

	pkg_name <- split_string(pkg_name)
	if (pkg_name$version == "NA") { pkg_name$version <- NULL }
	message("Installing package ", pkg_name$pkg_name, " with version ", ifelse(is.null(pkg_name$version), "latest", pkg_name$version), " from ", source)

	if (source == "CRAN") {
		remotes::install_version(pkg_name$pkg_name, version=pkg_name$version, upgrade="never", repos=c("https://cloud.r-project.org/"))
	}
	if (source == "bioc") {
		remotes::install_version(pkg_name$pkg_name, version=pkg_name$version, upgrade="never", repos=bioc_repos)
	}

	if ( ! library(pkg_name$pkg_name, character.only=TRUE, logical.return=TRUE) ) {
    	quit(status=1, save='no')
    }

}
