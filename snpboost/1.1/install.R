library(remotes)

split_string <- function(input_string) {
  # Split the string based on the version symbols
  parts <- strsplit(input_string, "==|<=|>=|<|>")[[1]]
  
  # Find the symbol used in the input string
  symbol <- regmatches(input_string, regexpr("==|<=|>=|<|>", input_string))
  
  # Return the parts and the symbol
  return(list(pkg_name = parts[1], version = paste(symbol, parts[2], sep = "")))
}

split_branch <- function(input_string) {
  # Split the string based on the version symbols
  parts <- strsplit(input_string, "--")[[1]]
  
  # Return the parts
  return(list(repo_address = parts[1], branch = parts[2]))
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
		pkg_name <- split_branch(pkg_name)
		message("Installing package from ", pkg_name$repo_address)
		if (is.na(pkg_name$branch)) {
			remotes::install_github(pkg_name)
		} else {
			message("Using branch ", pkg_name$branch)
			remotes::install_github(pkg_name$repo_address, ref=pkg_name$branch)
		}
		next
	}

	pkg_name <- split_string(pkg_name)
	if (pkg_name$version == "NA") { pkg_name$version <- NULL }
	message("Installing package ", pkg_name$pkg_name, " with version ", ifelse(is.null(pkg_name$version), "latest", pkg_name$version), " from ", source)

	if (source == "CRAN") {
		remotes::install_version(pkg_name$pkg_name, version=pkg_name$version, upgrade="never", repos=c("https://cloud.r-project.org/"))
	}
	if (source == "bioc") {
		remotes::install_version(pkg_name$pkg_name, version=pkg_name$version, upgrade="never", repos=c("https://bioconductor.org/packages/3.19/bioc"))
	}

	if ( ! library(pkg_name$pkg_name, character.only=TRUE, logical.return=TRUE) ) {
    	quit(status=1, save='no')
    }

}
