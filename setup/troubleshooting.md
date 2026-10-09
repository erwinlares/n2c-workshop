# Troubleshooting

This guide collects the problems I expect people to run into while setting up
for the "From the Notebook to the Cluster" workshops, and what to do about
each one. It is organized by what you see on screen, so search for the message
or the symptom you are looking at.

If your problem is not here, or the fix does not work, write to me at
<erwin.lares@wisc.edu> before the session. Please include three things: the
exact error message (copy and paste it, a screenshot is second best), the
output of the setup check, and the output of `sessionInfo()`. With those I can
usually tell what is going on in a single reply.

Sections:

- [Running the setup check](#running-the-setup-check)
- [R, Quarto, and Git (Day 1)](#r-quarto-and-git-day-1)
- [Installing the workshop packages (Day 1)](#installing-the-workshop-packages-day-1)
- [Creating and rendering a project (Day 1)](#creating-and-rendering-a-project-day-1)
- [Docker and Podman (Day 2)](#docker-and-podman-day-2)
- [GitLab (Day 2)](#gitlab-day-2)
- [CHTC (Day 3)](#chtc-day-3)
- [If you fall behind](#if-you-fall-behind)

## Running the setup check

**The `source()` line fails with a connection or certificate error.** Your
network, or a university or company proxy, is probably blocking the download.
Open the [script](check-setup.R) in a browser, save it as `check-setup.R`, and
run it from your own copy:

```r
source("check-setup.R")
```

The check only reads information from your machine, so running a saved copy
gives the same result.

**I only want to check one day.** Turn off the automatic run, load the script,
and call the function with the day you want:

```r
options(n2c.check.autorun = FALSE)
source("check-setup.R")
n2c_check(days = 2)
```

**Some items say `[INFO]` and never turn green.** That is intended. The GitLab
account and the CHTC account cannot be checked from your computer, so the script
only reminds you to confirm them yourself.

## R, Quarto, and Git (Day 1)

**R is older than 4.4.0.** Install a current R from
<https://cran.r-project.org/>, then restart your editor. Two follow-ups
follow. First, on macOS and Windows each minor version of R keeps
its own package library, so after a big upgrade you will need to reinstall the
packages (the three workshop packages, at least). Second, if your editor keeps
using the old R, tell it which one to use. In RStudio, that setting is under
Tools, Global Options, General, "R version". In Positron, use the interpreter
picker.

**Quarto, Git, Docker, or Podman is "not found" right after I installed it.**
Your editor reads the list of program locations (the `PATH`) once, when it
starts, so a program installed afterward is invisible to it. Quit the editor
completely and open it again. If it is still missing, open a terminal and run
`quarto --version` (or `git --version`). If the terminal cannot find it either,
the installation did not finish, so run the installer again.

**Git on macOS asks me to install command line developer tools.** Say yes. That
installs Git. You can also trigger it yourself by running
`xcode-select --install` in a terminal.

**I use Positron, and my project has no `.Rproj` file.** The lessons were
built in RStudio. `init_project()` creates the `.Rproj` file only when it runs
inside RStudio, so in Positron you will not have one, and you do not need it:
open the project folder with File, Open Folder (in RStudio, the equivalent is
File, Open Project). The `.here` file in the project root does the job `here`
needs. One side effect: `check_project()` will report the missing `.Rproj`
file as a failure, which you can ignore.

**I opened my new project and the lesson disappeared.** Opening a project
replaces the current window, so the lesson you had open in the editor is gone.
That is intended: the lesson lives in your browser at
<https://erwinlares.github.io/n2c-workshop/>, and you work in the one editor
session from there on.

**The data file downloaded with a `.txt` ending, or opened in the browser
instead of saving.** Use the file's page (the link in Task 1) and click
"Download raw file." If the ending is still wrong, rename the file to
`palmer-morphometrics-2024.csv`, or skip the browser and let R fetch it. Run
this from the folder where you want the file to land:

```r
download.file(
  "https://raw.githubusercontent.com/erwinlares/n2c-workshop/main/data/palmer-morphometrics-2024.csv",
  destfile = "palmer-morphometrics-2024.csv"
)
```

**Quarto is found, but "did not run".** Reinstall it from
<https://quarto.org/docs/get-started/>. If you use RStudio or Positron, the
copy bundled with the editor is normally enough, so a fresh editor update can
also fix it.

## Installing the workshop packages (Day 1)

Install the packages from a fresh R session that is not inside a project:

```r
install.packages("pak")
pak::pak("erwinlares/toolero")
pak::pak("erwinlares/containr")
pak::pak("erwinlares/submitr")
```

**"lazy-load database ... is corrupt" or "internal error in R_decompress1".**
This happens when you reinstall a package while an older copy of it is still
loaded in your R session. Nothing is permanently broken. Restart R (in RStudio,
Session, Restart R), run the install line again, and the problem goes away. If
it somehow persists, remove the package first and install it again:

```r
remove.packages("toolero")
pak::pak("erwinlares/toolero")
```

**The setup check says a package was "not installed from GitHub".** You have the
CRAN version, and the workshop uses the development version. Restart R and run
the `pak::pak("erwinlares/<package>")` line for that package.

**The setup check says a package has missing dependencies.** Restart R and run
the same `pak::pak()` line again. pak installs whatever is missing.

**The install says it needs to compile something and fails.** Most packages
install as ready-made binaries, but a few may need a compiler. On Windows,
install the [Rtools](https://cran.r-project.org/bin/windows/Rtools/) version
that matches your R. On macOS, run `xcode-select --install`. On Linux, install
your distribution's build tools and the system libraries named in the error
message. Then run the install again.

**"HTTP error 403" or "API rate limit exceeded" when installing from GitHub.**
GitHub limits anonymous requests, and a room full of people on one network can
hit the limit quickly. The fix is a GitHub personal access token:

```r
usethis::create_github_token()   # opens a page in your browser
gitcreds::gitcreds_set()         # paste the token when asked
```

Treat the token like a password: never paste it into an email, an issue, or a
chat message, including to me.

## Creating and rendering a project (Day 1)

**My new project does not contain toolero or pak.** That is expected. A project
created with `toolero::init_project()` starts with an empty project library,
and the lesson walks you through bringing packages in with `renv::hydrate()`
and `renv::snapshot()`. Those functions copy the packages you already installed
globally into the project, so the global installation in the previous section
has to be done first. If `renv::hydrate()` reports packages it could not find,
install them in a normal R session (outside the project), then run it again.

**R asks for the `ragg` package after I open my new project.** The lesson copies
`ragg` into the project along with the other packages, so this should not
happen. If it does, install `ragg` in a normal R session (outside the project),
then run `renv::hydrate(packages = "ragg")` in the project.

**`pak` is not available inside the project.** A project session may use a
restricted set of library paths. Install what you need in a normal R session
first, then hydrate the project as described above.

**A file is not found when I render a document, but the code works when I run
it by hand.** The working directory is different in the two cases. When Quarto
renders a document that lives in a subfolder, it uses that document's folder as
the working directory, and your relative paths no longer point where you think
they do. Build paths from the project root instead:

```r
here::here("data-raw", "palmer-morphometrics-2024.csv")
```

`here` finds the root by looking upward for a marker, and `init_project()`
writes an empty `.here` file in the project root for exactly that purpose. If
you moved a document out of the project, or created the folder some other way,
check that the `.here` file is still there.

**"object 'bill_length_mm' not found" (or a similar column name).** You probably
loaded the `penguins` dataset that ships with R 4.5 and later, which uses
different column names (`bill_len`, `bill_dep`, `flipper_len`, `body_mass`).
The workshop reads the CSV file from the repository's `data/` folder (you copy
it into your project's `data-raw/` folder), and it uses the palmerpenguins
names.
Read the CSV and the code will find its columns.

**There is no `morphometrics-analysis.R` in `R/` after I render.** The script is
written by a hook that only runs when the document was created with
`use_purl = TRUE`, and the default is `FALSE`. (`R/purl.R`, the hook itself, is
in that folder either way.) Recreate the document with
`create_qmd(use_purl = TRUE, overwrite = TRUE)`, copying your code out of the old
file first, since `overwrite = TRUE` replaces it. Then render again.

## Docker and Podman (Day 2)

You need one container engine, Docker or Podman. If you have both, either works.
Installation steps for each platform are in the
[README](../README.md#installing-a-container-engine).

**The setup check says the engine is "installed but not responding".** The
program is there, but the background service is not running.

- For Docker Desktop, open the application and wait until it says the engine is
  running, then run the check again.
- For Podman on macOS or Windows, start its virtual machine with
  `podman machine start`. If you have never created one, run
  `podman machine init` first.
- For Docker Engine on Linux, check the service with
  `sudo systemctl status docker` and start it with
  `sudo systemctl start docker` if needed.

**"permission denied" talking to the Docker socket (Linux).** Your user is not
in the `docker` group, so Docker only answers to `sudo`. Docker's
[post-installation steps](https://docs.docker.com/engine/install/linux-postinstall/)
explain how to add yourself to the group. You must log out and back in for the
change to take effect.

**WSL2 is missing or the wrong version (Windows).** In PowerShell opened as an
administrator, run `wsl --install` and restart when it asks. To see which
version your distribution uses, run:

```powershell
wsl.exe --list --verbose
```

The VERSION column should say 2. If it says 1, convert it with
`wsl.exe --set-version Ubuntu 2` (use your distribution's name from the list).
Microsoft's guide is [Install WSL](https://learn.microsoft.com/en-us/windows/wsl/install).

**Docker Desktop will not start on Windows, or complains that WSL is
incomplete or outdated.** Run `wsl --update` in an administrator PowerShell,
restart, and open Docker Desktop again. If it then reports that virtualization
is disabled, you need to turn it on in your computer's firmware (BIOS) settings.
You can check its current state in Task Manager, on the Performance tab, under
CPU, where it says "Virtualization: Enabled" or "Disabled". Because firmware
menus differ by manufacturer, searching for your computer's model plus "enable
virtualization" is the quickest route. If you are on a university-managed
laptop and cannot change this, write to me early.

**Docker Desktop on macOS will not open, or runs very slowly.** Check that you
downloaded the installer that matches your chip (Apple silicon or Intel). On
Apple silicon, Docker also recommends installing Rosetta with
`softwareupdate --install-rosetta`.

**Pulling an image fails or times out.** First check that you are online and not
behind a network that blocks the registry. Then try again in a few minutes, since
public registries can limit anonymous downloads when many people pull at once.
Pulling the images before the session, on a network you trust, avoids the
problem entirely. I will say which images in the lesson.

**I am running out of disk space.** Container images are large, often several
gigabytes in total. See what Docker is using with `docker system df`. You can
remove unused images and stopped containers with `docker system prune`, but read
its confirmation message first, because it deletes things.

## GitLab (Day 2)

**`podman login` or `docker login` to `registry.doit.wisc.edu` is rejected.**
The registry does not accept your NetID password. It expects a personal access
token, created in GitLab. My guide to creating one and logging in is at
<https://git.doit.wisc.edu/ERWIN.LARES/container-registry>. Check that the token
has registry scopes and has not expired.

**I cannot reach `git.doit.wisc.edu`.** Some services at the university are only
reachable from the campus network or through WiscVPN. Connect to WiscVPN and try
opening the address in a browser.

**I cannot sign in.** The DoIT GitLab service uses your NetID and Duo. Confirm that
you can sign in at <https://git.doit.wisc.edu>, and see the
[DoIT knowledge base article](https://kb.wisc.edu/shared-tools/page.php?id=121442)
for eligibility and setup. If you meet the requirements and still cannot get in,
the DoIT Help Desk is the right place to ask, since they control access.

**Git asks for a password and rejects it.** With single sign-on, GitLab usually
does not accept your normal password for Git commands. It expects a personal
access token or an SSH key instead. If you hit this, write to me and I will point
you to the steps for whichever the lesson uses.

## CHTC (Day 3)

**I have not heard back about my account.** CHTC says to expect a follow-up in 2
to 3 business days after you submit the
[account request form](https://chtc.cs.wisc.edu/uw-research-computing/form).
New research groups are first scheduled for a short consultation, so those
requests can take longer. If three business days pass with no reply, write to
CHTC at <chtc@cs.wisc.edu>. Please do not wait until the week of Day 3.

**The setup check says there is no SSH client.** Your computer needs an OpenSSH
client to talk to the cluster. macOS and most Linux systems include one. On
Windows 10 and 11 it is an optional feature: open Settings, search for "optional
features", and add "OpenSSH Client".

**I have an account but cannot log in.** Check that the login details in your
confirmation email match what you are typing, and that you have completed any
Duo setup that email asks for. Your account details come from CHTC, so questions
about access are best sent to <chtc@cs.wisc.edu>. I can help with how the
workshop uses the account once you can sign in.

## If you fall behind

Each day ends with a project in a known state, and a checkpoint of that state is
available as a download. If something goes wrong during a session and you cannot
recover in a few minutes, download the checkpoint for the next day and carry on.
You do not need to fix the earlier problem to keep up, and you can come back to
it afterward.

| If you could not finish | Download this checkpoint |
|-------------------------|--------------------------|
| Day 1 (toolero) | [`minimal-project-day2.zip`](https://github.com/erwinlares/n2c-workshop/releases/download/day2-checkpoint/minimal-project-day2.zip) |
| Day 2 (containr) | [`minimal-project-day3.zip`](https://github.com/erwinlares/n2c-workshop/releases/download/day3-checkpoint/minimal-project-day3.zip) |

Unzip the checkpoint, open the folder as a project in your editor, and follow the
lesson from there. If the folder contains an `renv.lock` file, `renv::restore()`
recreates the packages it lists. The checkpoints are posted the week of the
session that needs them, so the links will not work before then.