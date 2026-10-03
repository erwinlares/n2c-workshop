# From the Notebook to the Cluster

Participant materials for a three-day workshop series on taking an R analysis
from a notebook on your laptop to a high-throughput computing (HTC) cluster.
Each day uses one package, and each day builds on the last.

| Day | Date | Topic | Package |
|-----|------|-------|---------|
| 1 | Wednesday, October 7, 2026 | Scaffolding a reproducible project | [toolero](https://github.com/erwinlares/toolero) |
| 2 | Wednesday, October 14, 2026 | Containerizing it | [containr](https://github.com/erwinlares/containr) |
| 3 | Thursday, October 22, 2026 | Submitting it to a cluster | [submitr](https://github.com/erwinlares/submitr) |

**When:** 2:00 to 4:00 pm on each day.
**Where:** Computer Science 3139.
**What to bring:** a laptop with the software below installed.

The lessons are published at
<https://erwinlares.github.io/n2c-workshop/>. Day 2 and Day 3 appear there the
week they are taught.

## Before you arrive

Please work through this list before Day 1. Steps 1 to 4 take about 15 minutes
if nothing goes wrong, and they are meant to surface problems while there is
still time to fix them. The Day 2 and Day 3 requirements come after, and one of
them (the CHTC account) takes a few business days, so please start it early.

### Before Day 1

1. Install R, version 4.4.0 or later, and [RStudio](https://posit.co/download/rstudio-desktop/).
   I built the lessons in RStudio, so the screens and menu names match it.
   [Positron](https://positron.posit.co/) should work with little or no
   change, and the lessons point out the few places where it differs. If
   you already use Positron, you are welcome to stay with it.
2. Install [Quarto](https://quarto.org/docs/get-started/) and
   [Git](https://git-scm.com/downloads).
3. Start a fresh R session (not inside a project, and with none of these
   packages loaded) and install `readr` and `ggplot2` (Day 1 draws a figure
   from a CSV file) and the three workshop packages from GitHub. We use the
   development versions of all three:

   ```r
   install.packages(c("pak", "readr", "ggplot2"))
   pak::pak("erwinlares/toolero")
   pak::pak("erwinlares/containr")
   pak::pak("erwinlares/submitr")
   ```

   If R reports that a "lazy-load database" is corrupt, a package was loaded
   while you were reinstalling it. Restart R and run the install again.

4. Run the setup check. It reports what is missing and does not change
   anything on your machine:

   ```r
   source("https://raw.githubusercontent.com/erwinlares/n2c-workshop/main/setup/check-setup.R")
   ```

   (If you would rather read the script before running it, it lives in
   [`setup/check-setup.R`](setup/check-setup.R).)

### Before Day 2

Day 2 builds container images, so everyone needs two things.

1. **A container engine: Docker and/or Podman.** You need one of them, and
   either works. Platform-specific steps are in the next section.
2. **A GitLab account for `git.doit.wisc.edu`**, the UW-Madison DoIT GitLab
   service. Setup instructions are in the
   [DoIT knowledge base article](https://kb.wisc.edu/shared-tools/page.php?id=121442).
   You sign in with your NetID and Duo, so please test the login before the
   session.

Windows users also need WSL2 (Windows Subsystem for Linux, version 2), which
both Docker Desktop and Podman use on Windows.

### Before Day 3

Day 3 submits a job to the Center for High Throughput Computing (CHTC), so you
need a **CHTC account**. Request one with the
[CHTC account request form](https://chtc.cs.wisc.edu/uw-research-computing/form).
CHTC's page says to expect a follow-up in 2 to 3 business days after you submit
the form, and new research groups are first scheduled for a short consultation,
so please request your account well before October 22.

## Installing a container engine

Pick the section for your operating system. These instructions come from the
official documentation of each project, which is the best place to look if
something changes after this was written.

### Windows

1. **Install WSL2.** Open PowerShell as an administrator (right-click, then
   "Run as administrator") and run:

   ```powershell
   wsl --install
   ```

   Restart your computer when it asks, then finish the Ubuntu setup (it asks
   you to choose a Linux username and password). To confirm you are on
   version 2, run `wsl.exe --list --verbose` and check that the VERSION column
   says 2. Microsoft's guide is
   [Install WSL](https://learn.microsoft.com/en-us/windows/wsl/install).

2. **Install a container engine.** Choose one:

   - **Docker Desktop:** follow
     [Install Docker Desktop on Windows](https://docs.docker.com/desktop/setup/install/windows-install/).
     When the installer asks, choose "Use WSL 2 instead of Hyper-V," then start
     Docker Desktop from the Start menu and accept the license terms.
   - **Podman:** follow the
     [Podman installation page](https://podman.io/docs/installation) and the
     [Podman for Windows guide](https://github.com/containers/podman/blob/main/docs/tutorials/podman-for-windows.md).
     Podman runs inside a WSL2 virtual machine, and you can use it from
     PowerShell.

### macOS

Choose one:

- **Docker Desktop:** follow
  [Install Docker Desktop on Mac](https://docs.docker.com/desktop/setup/install/mac-install/).
  Download the installer for your chip (Apple silicon or Intel), open
  `Docker.dmg`, drag Docker to the Applications folder, launch it, and accept
  the license terms. On Apple silicon, Docker also recommends installing
  Rosetta with `softwareupdate --install-rosetta`.
- **Podman:** download the installer from the
  [Podman installation page](https://podman.io/docs/installation), then
  create and start the virtual machine Podman uses on macOS:

  ```bash
  podman machine init
  podman machine start
  podman info
  ```

### Linux

Choose one:

- **Docker Engine:** follow the page for your distribution under
  [Install Docker Engine](https://docs.docker.com/engine/install/) (for
  example, [Ubuntu](https://docs.docker.com/engine/install/ubuntu/)), and then
  the [post-installation steps](https://docs.docker.com/engine/install/linux-postinstall/)
  so you can run `docker` without `sudo`.
- **Podman:** it is in most distributions' package repositories. On Debian or
  Ubuntu, run `sudo apt-get update && sudo apt-get -y install podman`. On
  Fedora, run `sudo dnf -y install podman`. Other distributions are listed on
  the [Podman installation page](https://podman.io/docs/installation).

### Check that it works

Whichever engine you chose, confirm it responds before the session. For
Docker, run:

```bash
docker run hello-world
```

For Podman, run `podman info`. If either command fails, write to me (see
"Getting help" below) with the exact error message.

Docker Desktop's license terms depend on how it is used. Docker explains them
on the installation pages linked above, and Podman is a free alternative if you
would rather not think about it.

## Getting the materials

The easiest route is to let usethis download and unpack the repository for
you:

```r
usethis::use_course("erwinlares/n2c-workshop")
```

It asks where to put the folder and then opens it. If you prefer, use the
green **Code** button on this page and choose **Download ZIP**.

What is inside:

- `data/` holds the CSV file we start with. The second file is added when
  the lesson needs it (see the data note below).
- `setup/` holds the setup check and the troubleshooting guide.
- `docs/` holds the rendered lessons, which you can also read online at
  the address above.

## If you fall behind

Each day ends with a project in a known state. If something goes wrong and you
cannot recover during the session, download the checkpoint for the *next* day
and carry on from there. Nobody is penalized for using these, and you can
always return to your own project later.

| If you could not finish | Download this checkpoint |
|-------------------------|--------------------------|
| Day 1 (toolero) | [`minimal-project-day2.zip`](https://github.com/erwinlares/n2c-workshop/releases/download/day2-checkpoint/minimal-project-day2.zip) |
| Day 2 (containr) | [`minimal-project-day3.zip`](https://github.com/erwinlares/n2c-workshop/releases/download/day3-checkpoint/minimal-project-day3.zip) |

The Day 2 checkpoint is posted the week of Day 2, and the Day 3 checkpoint the
week of Day 3, so these links will not work before then.

## A note on the data

The CSV files we use (one in `data/` now, and a second added during Day 1)
use the column names from the palmerpenguins package, with units in the names (`bill_length_mm`, `bill_depth_mm`,
`flipper_length_mm`, `body_mass_g`).

R 4.5 and later also ship a `penguins` dataset in base R's `datasets`
package, but it names these columns differently (`bill_len`, `bill_dep`,
`flipper_len`, `body_mass`). If you load that version instead of the CSVs,
the lesson code will not find the columns it expects. The workshop always
reads the CSV files, so you do not need to load either package's data.

The split into "2024" and "2025" files is a teaching device. The original
measurements were collected between 2007 and 2009 (Gorman et al. 2014; see
`CITATION.cff`).

## Getting help

During the sessions, ask in the room. Between sessions, write to me directly
at <erwin.lares@wisc.edu>. If something fails, please include the exact error
message and the output of `sessionInfo()`. I would much rather hear about a
problem before the session than during it.

## How to cite

If you use these materials, GitHub's **Cite this repository** button (right
sidebar) gives you ready-made citations from `CITATION.cff`.

## License

The lesson text, figures, and documentation in this repository are licensed
under the [Creative Commons Attribution 4.0 International
License](LICENSE) (CC BY 4.0).

Code is licensed separately under the [MIT License](LICENSE-CODE). This covers
code snippets and code chunks shown in the lessons (R, shell, YAML, Dockerfile,
and HTCondor submit files), as well as scripts such as `setup/check-setup.R`.
You may reuse that code under MIT terms without attribution beyond keeping the
copyright notice.

The penguin data originate from the palmerpenguins package and the study cited
in the data note, and are released under CC0. The toolero, containr, and
submitr packages are separate projects with their own licenses.