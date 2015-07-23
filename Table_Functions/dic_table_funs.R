		#  Hurley et al Hierarchal Mule Deer Survival Table Functions
		#  Josh Nowak
		#  07/2015
#################################################################################
		extract_dic <- function(x){
			#  A function to extract DIC information from one model
			#  Takes the name of a model as it is stored
			#  Returns a data.frame
			load(file.path(getwd(), "plot_in", x))
			dic <- surv.res$BUGS$DIC
			pD <- surv.res$BUGS$pD
			deviance <- surv.res$BUGS$mean$deviance
			out <- data.frame(Model_Name = gsub(".RData", "", as.character(x)),
								DIC = round(dic, 1),
								pD = round(pD, 1),
								Deviance = round(deviance, 1),
								stringsAsFactors = F)
		return(out)
		}


		dic_wrapper <- function(model_names, word = F, doc_name){
			#  A function to automate extraction of DIC information from 1 or 
			#   many models
			#  Takes
			#  model_names - a character vector containing all the names of the
			#   models from which to extract DIC and related information
			
			out <- rbind_all(lapply(model_names, extract_dic)) %>%
					mutate(deltaDIC = DIC - min(DIC, na.rm = T)) %>%
					arrange(deltaDIC)
					
			if(word){
				doc_name <- paste(doc_name, ".Rmd", sep = "")
				#  Define YAML header
				cat("---", 
					"\ntitle: 'DIC Table'", 
					"\nauthor: 'Mark Hurley'",
					paste("\ndate:", format(Sys.time(), "%b %d, %Y")), 
					"\n---\n",
					file = paste(doc_name, sep = ""))
				#  Insert DIC table
				cat("\n\n\n",
					"```{r, echo = FALSE, results='asis'}\n\n",
					"\nkable(out, align = 'c')\n\n",
					"```",
					"\n\n-----\n\n",
					append = T, file = doc_name)					
				render(doc_name, "word_document")
				cat("\n\n", "Word document", paste(doc_name, ".docx", sep = ""),
					"saved in folder:", getwd(), 
					"\n\n")
				
				}
			
		return(out)
		}
		
		coef_report <- function(fixed_ef, doc_name){
			#  A function to create a word table from the output of get_fixedeff
			#  Takes
			#  fixed_ef which is the output of or a call to get_fixedeff
			#  doc_name the name of the resulting document
			fe <- data.frame(fixed_ef[,1:2], round(fixed_ef[,c(-1, -2)], 3))
			doc_name <- paste(doc_name, ".Rmd", sep = "")
			#  Define YAML header
			cat("---", 
				"\ntitle: 'Coefficient Table'", 
				"\nauthor: 'Mark Hurley'",
				paste("\ndate:", format(Sys.time(), "%b %d, %Y")), 
				"\n---\n",
				file = paste(doc_name, sep = ""))
			#  Insert DIC table
			cat("\n\n\n",
				"```{r, echo = FALSE, results='asis'}\n\n",
				"\nkable(fe, align = 'c')\n\n",
				"```",
				"\n\n-----\n\n",
				append = T, file = doc_name)					
			render(doc_name, "word_document")
			cat("\n\n", "Word document", paste(doc_name, ".docx", sep = ""),
				"saved in folder:", getwd(), 
				"\n\n")
		}