# check-setup.R
#
# Setup check for the "From the Notebook to the Cluster" workshop series.
# https://github.com/erwinlares/n2c-workshop
#
# What this does: it looks at your machine and reports, day by day, whether the
# software the workshop needs is in place. It uses base R only, so it runs even
# before you have installed anything else.
#
# What this does NOT do: it does not install, change, or write anything. It
# runs a few read-only commands (for example `git --version` and
# `docker info`) and makes a few network connections: a web request to the
# GitLab server used on Day 2, a test sign-in to GitLab over SSH using your
# existing keys (it only reads GitLab's greeting), and a brief connection to
# the CHTC login servers' SSH port to see whether your network can reach them.
#
# Usage (checks all three days):
#
#   source("https://raw.githubusercontent.com/erwinlares/n2c-workshop/main/setup/check-setup.R")
#
# To check only some days, turn off the automatic run first, then call the
# function yourself:
#
#   options(n2c.check.autorun = FALSE)
#   source("https://raw.githubusercontent.com/erwinlares/n2c-workshop/main/setup/check-setup.R")
#   n2c_check(days = 1)

n2c_check <- function(days = 1:3) {
    
    # ---- settings you may want to edit when the packages are frozen -----------
    min_r        <- "4.4.0"
    pkgs         <- c(toolero  = "erwinlares/toolero",
                      containr = "erwinlares/containr",
                      submitr  = "erwinlares/submitr")
    gitlab_url   <- "https://git.doit.wisc.edu"
    gitlab_ssh   <- "git@git.doit.wisc.edu"
    chtc_hosts   <- c("ap2001.chtc.wisc.edu", "ap2002.chtc.wisc.edu")
    # Address of the container registry that holds the fallback image, if any.
    # Example: "https://ghcr.io/v2/". NA skips the check.
    registry_url <- NA_character_
    
    # ---- small helpers --------------------------------------------------------
    results <- list()
    add <- function(day, item, status, detail = "", fix = "") {
        results[[length(results) + 1L]] <<- data.frame(
            day = day, item = item, status = status, detail = detail, fix = fix,
            stringsAsFactors = FALSE
        )
    }
    
    # Run a command and capture its output. Never errors; returns ok = FALSE
    # when the command is missing, fails, or takes longer than `timeout` seconds.
    run <- function(cmd, args = character(), timeout = 20) {
        out <- tryCatch(
            suppressWarnings(system2(cmd, args, stdout = TRUE, stderr = TRUE,
                                     timeout = timeout)),
            error = function(e) NULL
        )
        if (is.null(out)) return(list(ok = FALSE, out = character()))
        status <- attr(out, "status")
        list(ok = is.null(status) || status == 0L, out = as.character(out))
    }
    
    has <- function(cmd) nzchar(Sys.which(cmd))
    
    is_installed <- function(pkg) nzchar(system.file(package = pkg))
    
    # TRUE if a web address answers at all (even with a login prompt).
    reachable <- function(url) {
        h <- tryCatch(suppressWarnings(curlGetHeaders(url, timeout = 10)),
                      error = function(e) NULL)
        code <- if (is.null(h)) NA_integer_ else as.integer(attr(h, "status"))
        !is.na(code) && code < 500
    }
    
    # TRUE if a TCP connection to host:port opens within a few seconds.
    port_open <- function(host, port) {
        con <- tryCatch(
            suppressWarnings(socketConnection(host, port = port, open = "r+b",
                                              blocking = TRUE, timeout = 8)),
            error = function(e) NULL
        )
        if (is.null(con)) return(FALSE)
        close(con)
        TRUE
    }
    
    is_windows <- .Platform$OS.type == "windows"
    
    base_pkgs <- rownames(utils::installed.packages(priority = "base"))
    
    # Hard dependencies of an installed package that are not installed.
    missing_deps <- function(pkg) {
        d <- utils::packageDescription(pkg)
        raw <- c(d$Depends, d$Imports)
        if (!length(raw)) return(character())
        deps <- strsplit(gsub("\\s+", " ", paste(raw, collapse = ",")), ",")[[1]]
        deps <- trimws(sub("\\(.*\\)", "", deps))
        deps <- setdiff(deps[nzchar(deps)], c("R", base_pkgs))
        deps[!vapply(deps, is_installed, logical(1))]
    }
    
    # ---- Day 1 ----------------------------------------------------------------
    if (1 %in% days) {
        
        rv <- getRversion()
        add(1, "R version",
            if (rv >= min_r) "OK" else "FAIL",
            paste("R", as.character(rv)),
            sprintf("Install R %s or later from https://cran.r-project.org/ and restart your editor.", min_r))
        
        # RStudio and Positron bundle Quarto and expose it through QUARTO_PATH.
        quarto <- unname(Sys.which("quarto"))
        if (!nzchar(quarto)) {
            qp <- Sys.getenv("QUARTO_PATH")
            if (nzchar(qp) && file.exists(qp)) quarto <- qp
        }
        if (nzchar(quarto)) {
            v <- run(shQuote(quarto), "--version")
            add(1, "Quarto", if (v$ok) "OK" else "WARN",
                if (v$ok) paste("version", v$out[1]) else "found, but did not run",
                if (v$ok) "" else "Reinstall Quarto from https://quarto.org/docs/get-started/")
        } else {
            add(1, "Quarto", "FAIL", "not found",
                "Install Quarto from https://quarto.org/docs/get-started/ and restart your editor.")
        }
        
        if (has("git")) {
            v <- run("git", "--version")
            add(1, "Git", "OK", if (v$ok) v$out[1] else "found")
        } else {
            add(1, "Git", "FAIL", "not found",
                "Install Git from https://git-scm.com/downloads and restart your editor.")
        }
        
        add(1, "pak package",
            if (is_installed("pak")) "OK" else "WARN",
            if (is_installed("pak")) "installed" else "not installed",
            'Run install.packages("pak") in a fresh R session.')
        
        # Task 1 and Task 3 of the Day 1 lesson load these two, and
        # renv::hydrate() can only copy packages that are already installed.
        for (p in c("readr", "ggplot2","rmarkdown")) {
            add(1, paste0(p, " package"),
                if (is_installed(p)) "OK" else "FAIL",
                if (is_installed(p)) "installed" else "not installed",
                sprintf('In a fresh R session, run install.packages("%s")', p))
        }
        
        for (p in names(pkgs)) {
            label <- paste0(p, " package")
            if (!is_installed(p)) {
                add(1, label, "FAIL", "not installed",
                    sprintf('In a fresh R session, run pak::pak("%s")', pkgs[[p]]))
                next
            }
            d <- utils::packageDescription(p)
            sha <- if (is.null(d$RemoteSha)) "" else d$RemoteSha
            if (!identical(d$RemoteType, "github")) {
                add(1, label, "WARN",
                    sprintf("version %s, not installed from GitHub", d$Version),
                    sprintf('The workshop uses the development version. Restart R, then run pak::pak("%s")', pkgs[[p]]))
            } else {
                add(1, label, "OK",
                    sprintf("version %s from GitHub (commit %s)", d$Version,
                            substr(sha, 1, 7)))
                md <- missing_deps(p)
                if (length(md)) {
                    add(1, paste(p, "dependencies"), "FAIL",
                        paste("missing:", paste(md, collapse = ", ")),
                        sprintf('Restart R, then run pak::pak("%s") to install what is missing.', pkgs[[p]]))
                }
            }
        }
    }
    
    # ---- Day 2 ----------------------------------------------------------------
    if (2 %in% days) {
        
        found <- Filter(has, c("docker", "podman"))
        working <- character()
        broken <- character()
        for (e in found) {
            if (run(e, "info", timeout = 30)$ok) working <- c(working, e)
            else broken <- c(broken, e)
        }
        if (length(working)) {
            add(2, "Container engine (Docker or Podman)", "OK",
                paste("working:", paste(working, collapse = ", ")))
        } else if (length(broken)) {
            add(2, "Container engine (Docker or Podman)", "FAIL",
                paste("installed but not responding:", paste(broken, collapse = ", ")),
                "Start Docker Desktop. For Podman on macOS or Windows, run 'podman machine start'. Then run this check again.")
        } else {
            add(2, "Container engine (Docker or Podman)", "FAIL",
                "neither docker nor podman found",
                "See 'Installing a container engine' in the README. If you just installed one, restart R or your editor so it can find it.")
        }
        
        if (is_windows) {
            old <- Sys.getenv("WSL_UTF8", unset = NA_character_)
            Sys.setenv(WSL_UTF8 = "1")   # asks wsl.exe for plain text output
            r <- run("wsl.exe", c("--list", "--verbose"))
            if (is.na(old)) Sys.unsetenv("WSL_UTF8") else Sys.setenv(WSL_UTF8 = old)
            
            lines <- trimws(gsub("[\r*]", "", r$out))
            lines <- lines[nzchar(lines) & !grepl("VERSION", lines)]
            if (!r$ok && !length(lines)) {
                add(2, "WSL2", "FAIL", "WSL is not installed or did not respond",
                    "In PowerShell opened as administrator, run 'wsl --install', restart, and finish the Ubuntu setup.")
            } else if (!length(lines)) {
                add(2, "WSL2", "WARN", "could not read WSL status",
                    "In PowerShell, run 'wsl.exe --list --verbose' and check that the VERSION column says 2.")
            } else if (any(grepl("\\s2$", lines))) {
                add(2, "WSL2", "OK", "a WSL 2 distribution is installed")
            } else {
                add(2, "WSL2", "WARN", "WSL is installed, but not as version 2",
                    "In PowerShell, run 'wsl.exe --set-version Ubuntu 2' (use your distribution's name).")
            }
        }
        
        if (reachable(gitlab_url)) {
            add(2, "GitLab server reachable", "OK", paste(gitlab_url, "responded"))
        } else {
            add(2, "GitLab server reachable", "WARN",
                paste("could not reach", gitlab_url),
                "You may need to be on the campus network or WiscVPN. Try opening the address in a browser.")
        }
        add(2, "GitLab account", "INFO",
            "cannot be checked from here",
            "Sign in at https://git.doit.wisc.edu with your NetID and Duo before Day 2.")
        
        # GitLab over SSH: needs an SSH client, a key, and the key added to GitLab.
        if (!has("ssh")) {
            add(2, "SSH client", "FAIL", "not found",
                "Install or enable an OpenSSH client. On Windows 10 and 11 it is an optional feature (Settings, Optional features, OpenSSH Client).")
        } else {
            add(2, "SSH client", "OK", "found")
            ssh_dir <- file.path(Sys.getenv(if (is_windows) "USERPROFILE" else "HOME"), ".ssh")
            keys <- list.files(ssh_dir, pattern = "^id_.*\\.pub$")
            if (!length(keys)) {
                add(2, "SSH key", if (is_windows) "INFO" else "WARN",
                    "no public key found in your .ssh folder",
                    "Create one with 'ssh-keygen -t ed25519', then add the .pub file to your GitLab profile under SSH Keys. If you use WSL, your keys live inside WSL and this check cannot see them.")
            } else {
                add(2, "SSH key", "OK", sprintf("%d public key file(s) found", length(keys)))
                # BatchMode stops ssh from prompting, so this can never hang waiting for input.
                r <- run("ssh", c("-T", "-o", "BatchMode=yes", "-o", "ConnectTimeout=10",
                                  gitlab_ssh), timeout = 30)
                txt <- paste(r$out, collapse = " ")
                if (grepl("Welcome to GitLab", txt, fixed = TRUE)) {
                    add(2, "GitLab SSH sign-in", "OK", "GitLab accepted your SSH key")
                } else if (grepl("Permission denied", txt, fixed = TRUE)) {
                    add(2, "GitLab SSH sign-in", "WARN", "GitLab did not accept your SSH key",
                        "Add your public key to your GitLab profile under SSH Keys. If the key has a passphrase, make sure it is loaded in ssh-agent.")
                } else if (grepl("Host key verification failed", txt, fixed = TRUE)) {
                    add(2, "GitLab SSH sign-in", "INFO", "this computer has not trusted GitLab's host key yet",
                        sprintf("Run 'ssh -T %s' once in a terminal and answer yes when it asks.", gitlab_ssh))
                } else {
                    add(2, "GitLab SSH sign-in", "INFO", "could not complete the test",
                        "Not necessarily a problem. Try 'ssh -T git@git.doit.wisc.edu' in a terminal, or ask me.")
                }
            }
        }
        
        if (!is.na(registry_url)) {
            if (reachable(registry_url)) {
                add(2, "Image registry reachable", "OK", paste(registry_url, "responded"))
            } else {
                add(2, "Image registry reachable", "WARN", paste("could not reach", registry_url),
                    "Check your network connection. The fallback image is downloaded from this registry.")
            }
        }
    }
    
    # ---- Day 3 ----------------------------------------------------------------
    if (3 %in% days) {
        add(3, "SSH client",
            if (has("ssh")) "OK" else "FAIL",
            if (has("ssh")) "found" else "not found",
            "Install or enable an OpenSSH client; it is how your computer talks to the cluster. On Windows 10 and 11 it is an optional feature (Settings, Optional features, OpenSSH Client).")
        
        if (any(vapply(chtc_hosts, port_open, logical(1), port = 22))) {
            add(3, "CHTC login servers reachable", "OK", "your network can reach them")
        } else {
            add(3, "CHTC login servers reachable", "WARN", "could not reach them",
                "CHTC login requires the campus network or WiscVPN. Connect to WiscVPN and run this check again.")
        }
        
        if (is_windows) {
            add(3, "Reusing your SSH login", "INFO",
                "Windows' built-in ssh cannot keep a connection open",
                "CHTC recommends WSL (or MobaXTerm, WinSCP, or PuTTY) for connection reuse. Without it, Duo may ask you to confirm every time you connect.")
        }
        
        add(3, "CHTC account", "INFO",
            "cannot be checked from here",
            "Request one at https://chtc.cs.wisc.edu/uw-research-computing/form. CHTC replies in 2 to 3 business days.")
    }
    
    # ---- report ---------------------------------------------------------------
    res <- do.call(rbind, results)
    tags <- c(OK = "[ OK ]", WARN = "[WARN]", FAIL = "[FAIL]", INFO = "[INFO]")
    titles <- c("1" = "Before Day 1 (toolero)",
                "2" = "Before Day 2 (containr)",
                "3" = "Before Day 3 (submitr)")
    
    cat("\nWorkshop setup check\n")
    os <- utils::sessionInfo()$running
    if (is.null(os)) os <- R.version$platform
    cat(sprintf("%s on %s\n", R.version.string, os))
    
    for (d in intersect(1:3, days)) {
        cat("\n", titles[[as.character(d)]], "\n", sep = "")
        rows <- res[res$day == d, , drop = FALSE]
        for (i in seq_len(nrow(rows))) {
            detail <- if (nzchar(rows$detail[i])) paste0(": ", rows$detail[i]) else ""
            cat(sprintf("  %s %s%s\n", tags[[rows$status[i]]], rows$item[i], detail))
            if (rows$status[i] %in% c("FAIL", "WARN", "INFO") && nzchar(rows$fix[i])) {
                cat(strwrap(paste("->", rows$fix[i]), indent = 9, exdent = 12), sep = "\n")
            }
        }
    }
    
    n_fail <- sum(res$status == "FAIL")
    n_warn <- sum(res$status == "WARN")
    cat(sprintf("\nSummary: %d to fix, %d to look at.\n", n_fail, n_warn))
    if (n_fail + n_warn == 0) {
        cat("Everything this script can check looks good.\n")
    } else {
        cat("Fix the [FAIL] items, then run the check again.\n")
        cat("If you get stuck, email this output to erwin.lares@wisc.edu.\n")
    }
    
    invisible(res)
}

if (isTRUE(getOption("n2c.check.autorun", TRUE))) n2c_check()