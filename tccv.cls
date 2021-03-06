% Copyright (C) 2012,2014  Nicola Fontana <ntd at entidi.it>
%
% This program can be redistributed and/or modified under
% the terms of the LaTeX Project Public License, either
% version 1.3 of this license or (at your option) any later
% version. The latest version of this license is in
%   http://www.latex-project.org/lppl.txt
% and version 1.3 or later is part of all LaTeX distributions
% version 2005/12/01 or later.
%
% Based on the original idea by Alessandro Plasmati found at
% http://www.latextemplates.com/template/two-column-one-page-cv
%
% The most relevant changes from his work are:
%
% * this is a class, not a template document;
% * tccv is based on scrartcl (from Koma-script), not on article;
% * the fonts are selected from the PSNFSS collection, so no
%   custom font installation should be required;
% * heavily based the implementation on custom environments and
%   macros, so the document is much easier to read (and customize);
% * it is plain LaTeX/Koma-script, so the CV can be compiled
%   with the usual tools, latex and pdflatex included.

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{tccv}
              [2015/04/16 v1.2.2
 Two Column Curriculum Vitae]

\LoadClassWithOptions{scrartcl}

\setcounter{secnumdepth}{-1}
\RequirePackage[letterpaper,hmargin=1cm,vmargin=0.5cm]{geometry} %,twocolumn,columnsep=.5cm]{geometry}
\RequirePackage{bookman,etoolbox,needspace,pifont,tabularx,xcolor,booktabs}
\RequirePackage{hyperref,fontawesome,setspace,titlesec}

% Capitalize words of at least a minimum length (default to 3 chars).
% The text is capitalized before being expanded.
%
% This macro uses Lua to do the job but fails gracefully (that is,
% return the text as is) if \directlua is not available.
%
%     \ucwords
%         [optional: miminum length]{text}
\newcommand\ucwords[2][3]{%
    % Fails gracefully if not in LuaLaTeX
    \providecommand\directlua[1]{#2}%
    \directlua{%
	local minlen = tonumber("#1")
	local src = "\luaescapestring{\unexpanded{#2}}"
	local dst = {}
	% Put a % inside \directlua is tricky as hell. Use char(37)
	% instead: still no plans for supporting non-ASCII platforms.
	for w in src:gmatch(string.char(37) .. "S+") do
	    if w:len() >= minlen then
		table.insert(dst, w:sub(1,1):upper() .. w:sub(2))
	    else
		table.insert(dst, w)
	    end
	end
	tex.print(dst)}}

\pagestyle{empty}
\setlength\parindent{0pt}
\color[HTML]{303030} % Default foreground color
\definecolor{link}{HTML}{506060} % Hyperlinks
\hypersetup{colorlinks,breaklinks,urlcolor=link,linkcolor=link}
\setkomafont{disposition}{\color[HTML]{801010}}
\setkomafont{section}{\scshape\large\mdseries}

% Addition to this class by Sam Delmerico.
\newcommand{\Header}[7]{
    \begin{minipage}[c]{0.2\textwidth}
        {\usekomafont{part}\selectfont\huge #1}
        {\usekomafont{part}\selectfont\large #3}
        \vspace{7pt}
    \end{minipage}
    \begin{minipage}[r]{0.8\textwidth}
        \begin{flushright}
        \colorbox[HTML]{F5DD9D}{
            \begin{tabular}{clrc}
                \faPhone & #2 & \href{mailto:#4}{#4} & \faEnvelopeO \\
                 \faGithub & \href{https://#5}{#5} & \href{https://#6}{#6} & \faLinkedin 
            \end{tabular}
        }
        \end{flushright}
    \end{minipage}
}

% In tccv \part must contain the subject of the curriculum vitae.
% The command will start a new page and output in onecolumn the
% subject (first and last name) with the text from the optional
% argument underneath it
\renewcommand\part[2][Curriculum Vitae]{%
    \twocolumn[%
    \begin{center}
	\vskip-\lastskip%
	{\usekomafont{part} #2} \medskip\\
	{\selectfont\Large {#1}}
	\bigskip
    \end{center}]}

% Overrides the \section command to capitalize every
% word for cosmetic purposes and draws a rule under it.
% \titlespacing*{\section}  
% {0pt}{9.5ex}{2.3ex}
\let\old@section\section
\renewcommand\section[2][]{%
    \old@section[#1]{\ucwords{#2}}%
    \newdimen\raising%
    \raising=\dimexpr-0.7\baselineskip\relax%
    \vskip\raising\hrule height 0.4pt\vskip-\raising}

% Allow conditionals based on the job name. This can usually be set
% from a command-line argument: check fausto.en.tex for an example.
%
%     \ifjob
%         {jobname}
%         {content if matches}
%         {content if does not match}
\newcommand\ifjob[3]{%
    \edef\JOBNAME{\jobname}%
    \edef\PIVOT{\detokenize{#1}}%
    \ifdefstrequal{\JOBNAME}{\PIVOT}{#2}{#3}%
}

% Renders a personal data box:
%
%     \personal
%         [url without scheme, i.e. no http:// prefix]
%         {address}
%         {phone number}
%         {email}
\newcommand\personal[5][]{%
    \newcommand\SYMBOL[1]{\raisebox{-2pt}{\Large\ding{##1}}}%
    \needspace{0.5\textheight}%
    \newdimen\boxwidth%
    \boxwidth=\dimexpr\linewidth-2\fboxsep\relax%
    \colorbox[HTML]{F5DD9D}{%
    \begin{tabularx}{\boxwidth}{c|X}
    \SYMBOL{37} & {#2}\smallskip\\
    \SYMBOL{41} & \href{mailto:#3}{#3}
    \ifstrempty{#1}{}{\smallskip\\ \SYMBOL{218} & \href{http://#1}{#1}}
    \ifstrempty{#5}{}{\smallskip\\ \SYMBOL{218} & \href{http://#4}{#4}}
    \end{tabularx}}}

% Every \item can be followed by one or more paragraphs
% of description:
%
%     \item
%         {date range}
%         {company}
%         {role}
%     One or more paragraphs describing what achieved during this application.
\newenvironment{eventlist}{%
    \newcommand*\inskip{}
    \renewcommand\item[3]{
    	\inskip
    % 	{\raggedleft\textsc{##1}\\[1pt]}
    	{\normalsize\textbf{\textit{##3}}\\[2pt]}
    % 	\ifstrempty{##2}{}{\emph{##2}}
    	\newcolumntype{R}{>{\raggedleft\arraybackslash}X}
    	\begin{tabularx}{\textwidth}{lR}
        	\ifstrempty{##2}{}{##2} &
        	{\textsc{##1}\\[1pt]}
    	\end{tabularx}
    	
    	\renewcommand\inskip{\bigskip}
    }
}

% Use only \item inside this environment, no other macros
% are allowed:
%
%     \item
%         [what has been achieved]
%         {years}
%         {subject}
%         {notes}
\newenvironment{yearlist}{%
    \renewcommand\item[4][]{%
	\textsc{##2} & \textbf{##3} \\
	\ifstrempty{##1}{}{& \textsc{##1} \\}
	& \textit{##4}\medskip\\}
    \tabularx{\linewidth}{rX}}
    {\endtabularx}


% Use only \item inside this environment: no other macros
% are allowed:
%
%     \item
%         {fact}
%         {description}
\newenvironment{factlist}{%
    \newdimen\unbaseline
    \unbaseline=\dimexpr-\baselinestretch\baselineskip\relax
    \renewcommand\item[2]{%
	\textsc{##1} & {\raggedright ##2\medskip\\}\\[\unbaseline]}
    \tabularx{\linewidth}{rX}}
    {\endtabularx}

% Avoid dealing with starred sections
% See the following question for further details:
% http://tex.stackexchange.com/questions/223607/does-the-bibliography-command-specify-a-section-anywhere
\KOMAoption{bibliography}{totocnumbered}

\AtEndPreamble{%
	\@ifpackageloaded{biblatex}{%
		\defbibheading{bibliography}[\refname]{%
			\section{#1}%
		}%
	}{}%
}
%%
%% End of file `tccv.cls'.
