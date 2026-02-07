% ----------------------------------------------------------------------------
% Copyright (C) 2015-2025 by USTC TeX Users Group
%   <https://github.com/ustctug/>
%
% Copyright (C) 2026 by LiKunfeng
%
% This file is part of the xynuthesis package.
%
% Derived work notice:
% This template is a derived work based on the ustcthesis template.
% Upstream base: ustcthesis v<4.0.0-beta.10>  
%
%
% This work may be distributed and/or modified under the
% conditions of the LaTeX Project Public License, either version 1.3c
% of this license or (at your option) any later version.
% The latest version of this license is in
%    https://www.latex-project.org/lppl.txt
% and version 1.3c or later is part of all distributions of LaTeX
% version 2008 or later.
%
% This work has the LPPL maintenance status `maintained'.
% The Current Maintainer of this work is [LiKunfeng].
%
% Note:
% Modified versions of this file must be renamed to avoid confusion with
% the original.
%
% ----------------------------------------------------------------------------
% Acknowledgement:
% This template is primarily a derived work based on the 'ustcthesis' template
% by USTC TeX Users Group.
% It also references the implementation logic of 'ThuThesis' by Tsinghua University 
% TUNA Association. We thank both teams for their excellent work.
%

\NeedsTeXFormat{LaTeX2e}[2017/04/15]
\newcommand\xynuthesisversion{0.0.1}
\ProvidesClass{xynuthesis}[2026/01/11 v\xynuthesisversion\space  XYNU thesis template]

% 报错和警告
\newcommand\xynu@error[1]{%
  \ClassError{xynuthesis}{#1}{}%
}
\newcommand\xynu@warning[1]{%
  \ClassWarning{xynuthesis}{#1}%
}

\newcommand\xynu@deprecated[3]{%
  \xynu@warning{The #1 is deprecated since #2. Use #3 instead.}%
}

% 检查 \LaTeXe{} kernel 版本
\@ifl@t@r\fmtversion{2017/04/15}{}{
  \xynu@error{%
    TeX Live 2017 or later version is required to compile this document%
  }
}

% 检查编译引擎，要求使用 XeLaTeX 或 LuaLaTeX。
\RequirePackage{iftex}
\ifXeTeX\else
  \ifLuaTeX\else
    \xynu@error{XeLaTeX or LuaLaTeX is required to compile this document}
  \fi
\fi


% \subsection{处理选项}

\RequirePackage{kvdefinekeys}
\RequirePackage{kvsetkeys}
\RequirePackage{kvoptions}

% 提供一个 \cs{xynusetup} 命令支持 \emph{key-value} 的方式来设置。
\let\xynu@setup@hook\@empty
\newcommand\xynusetup[1]{%
  \let\xynu@setup@hook\@empty
  \kvsetkeys{xynu}{#1}%
  \xynu@setup@hook
}

% 同时用 \emph{key-value} 的方式来定义这些接口：
% \begin{latex}
%   \xynu@define@key{
%     <key> = {
%       name = <name>,
%       choices = {
%         <choice1>,
%         <choice2>,
%       },
%       default = <default>,
%       code = <code>,
%     },
%   }
% \end{latex}

% 其中 |choices| 设置允许使用的值，默认为第一个（或者 \meta{default}）；
% \meta{code} 是相应的内容被设置时执行的代码。

\newcommand\xynu@define@key[1]{%
  \kvsetkeys{xynu@key}{#1}%
}
\kv@set@family@handler{xynu@key}{%
%
% \cs{xynusetup} 会将 \meta{value} 存到 \cs{xynu@\meta{key}}，
% 但是宏的名字包含 “-” 这样的特殊字符时不方便直接调用，比如 |key = math-style|，
% 这时可以用 |name| 设置 \meta{key} 的别称，比如 |key = math@style|，
% 这样就可以通过 \cs{xynu@math@style} 来引用。
% |default| 是定义该 \meta{key} 时默认的值，缺省为空。
%
  \@namedef{xynu@#1@@name}{#1}%
  \def\xynu@@default{}%
  \def\xynu@@choices{}%
  \kv@define@key{xynu@value}{name}{%
    \@namedef{xynu@#1@@name}{##1}%
  }%
  %
  % 由于在定义接口时，\cs{xynu@\meta{key}@@code} 不一定有定义，
  % 而且在文档类/宏包中还有可能对该 |key| 的 |code| 进行添加。
  % 所以 \cs{xynu@\meta{key}@@code} 会检查如果在定义文档类/宏包时则推迟执行，否则立即执行。
  %
  \@namedef{xynu@#1@@check}{}%
  \@namedef{xynu@#1@@code}{}%
  %
  % 保存下 |choices = {}| 定义的内容，在定义 \cs{xynu@\meta{name}} 后再执行。
  %
  \kv@define@key{xynu@value}{choices}{%
    \def\xynu@@choices{##1}%
    \@namedef{xynu@#1@@reset}{}%
    %
    % \cs{xynu@\meta{key}@check} 检查 |value| 是否有效，
    % 并设置 \cs{ifxynu@\meta{name}@\meta{value}}。
    %
    \@namedef{xynu@#1@@check}{%
      \@ifundefined{%
        ifxynu@\@nameuse{xynu@#1@@name}@\@nameuse{xynu@\@nameuse{xynu@#1@@name}}%
      }{%
        \xynu@error{Invalid value "#1 = \@nameuse{xynu@\@nameuse{xynu@#1@@name}}"}%
      }%
      \@nameuse{xynu@#1@@reset}%
      \@nameuse{xynu@\@nameuse{xynu@#1@@name}@\@nameuse{xynu@\@nameuse{xynu@#1@@name}}true}%
    }%
  }%
  \kv@define@key{xynu@value}{default}{%
    \def\xynu@@default{##1}%
  }%
  \kvsetkeys{xynu@value}{#2}%
  \@namedef{xynu@\@nameuse{xynu@#1@@name}}{}%
  %
  % 第一个 \meta{choice} 设为 \meta{default}，
  % 并且对每个 \meta{choice} 定义 \cs{ifxynu@\meta{name}@\meta{choice}}。
  %
  \kv@set@family@handler{xynu@choice}{%
    \ifx\xynu@@default\@empty
      \def\xynu@@default{##1}%
    \fi
    \expandafter\newif\csname ifxynu@\@nameuse{xynu@#1@@name}@##1\endcsname
    \expandafter\g@addto@macro\csname xynu@#1@@reset\endcsname{%
      \@nameuse{xynu@\@nameuse{xynu@#1@@name}@##1false}%
    }%
  }%
  \kvsetkeys@expandafter{xynu@choice}{\xynu@@choices}%
  %
  % 将 \meta{default} 赋值到 \cs{xynu@\meta{name}}，如果非空则执行相应的代码。
  %
  \expandafter\let\csname xynu@\@nameuse{xynu@#1@@name}\endcsname\xynu@@default
  \expandafter\ifx\csname xynu@\@nameuse{xynu@#1@@name}\endcsname\@empty\else
    \@nameuse{xynu@#1@@check}%
  \fi
  %
  % 定义 \cs{xynusetup} 接口。
  %
  \kv@define@key{xynu}{#1}{%
    \@namedef{xynu@\@nameuse{xynu@#1@@name}}{##1}%
    \@nameuse{xynu@#1@@check}%
    \@nameuse{xynu@#1@@code}%
  }%
}

% 定义接口向 |key| 添加 |code|：

\newcommand\xynu@option@hook[2]{%
  \expandafter\g@addto@macro\csname xynu@#1@@code\endcsname{#2}%
}

\xynu@define@key{
  degree = {
    choices = {
      master,
    },
    default = master,
  },
  degree-type = {
    name = degree@type,
    choices = {
      academic,
      professional,
      engineering,
    },
    default = academic,
  },
  main-language = {
    name = main@language,
    choices = {
      chinese,
      english,
    },
    default = chinese,
  },
  language = {
    choices = {
      chinese,
      english,
    },
    default = chinese,
  },
  system = {
    choices = {
      auto,
      mac,
      unix,
      windows,
    },
    default = auto,
  },
  fontset = {
    choices = {
      auto,
      windows,
      mac,
      ubuntu,
      fandol,
      none,
    },
    default = auto,
  },
  font = {
    choices = {
      auto,
      times,
      termes,
      stix,
      xits,
      libertinus,
      newcm,
      lm,
      newtx,
      none,
    },
    default = auto,
  },
  cjk-font = {
    name = cjk@font,
    choices = {
      auto,
      windows,
      mac,
      noto,
      fandol,
      none,
    },
    default = auto,
  },
  math-font = {
    name = math@font,
    choices = {
      auto,
      stix,
      xits,
      libertinus,
      newcm,
      cm,
      lm,
      newtx,
      none,
    },
    default = auto,
  },
  math-style = {
    name = math@style,
    choices = {
      GB,
      ISO,
      TeX,
    },
  },
  uppercase-greek = {
    name = uppercase@greek,
    choices = {
      italic,
      upright,
    },
  },
  less-than-or-equal = {
    name = leq,
    choices = {
      slanted,
      horizontal,
    },
  },
  integral = {
    choices = {
      upright,
      slanted,
    },
  },
  integral-limits = {
    name = integral@limits,
    choices = {
      true,
      false,
    },
  },
  partial = {
    choices = {
      upright,
      italic,
    },
  },
  math-ellipsis = {
    name = math@ellipsis,
    choices = {
      centered,
      lower,
      AMS,
    },
  },
  real-part = {
    name = real@part,
    choices = {
      roman,
      fraktur,
    },
  },
  cite-style = {
    name = cite@style,
    choices = {
      super,
      inline,
      authoryear,
    },
  },
  output = {
    choices = {
      print,
      electronic,
    },
    default = print,
  },
  badge-color = {
    name = badge@color,
    choices = {
      blue,
      black,
    },
    default = blue,
  },
  eqn-paren-style = {
    name = eqn@paren@style,
    choices = {
      full,
      half,
    }
  },
}

% 将 \xynu@cite@style 置空方便后续进行判断。
\def\xynu@cite@style{}

% 使用 \pkg{kvoptions} 提供的 key-value 接口，
\SetupKeyvalOptions{
  family  = xynu,
  prefix  = xynu@,
  setkeys = \kvsetkeys,
}

% 设置默认 \option{openany}。
\DeclareBoolOption[false]{openright}
\DeclareComplementaryOption{openany}{openright}

% 兼容旧版本的文档类选项。
% Deprecated since 2020-07-01.
\DeclareVoidOption{master}{\xynusetup{degree=master}}
\DeclareVoidOption{chinese}{\xynusetup{language=chinese}}
\DeclareVoidOption{english}{\xynusetup{language=english}}
\DeclareVoidOption{academic}{\xynusetup{degree-type=academic}}
\DeclareVoidOption{professional}{\xynusetup{degree-type=professional}}
\DeclareVoidOption{engineering}{\xynusetup{degree-type=engineering}}
\DeclareVoidOption{print}{\xynusetup{output=print}}
\DeclareVoidOption{pdf}{\xynusetup{output=electronic}}
\newif\ifxynu@legacy@cite@style
\DeclareVoidOption{super}{\xynusetup{cite-style=super}\xynu@legacy@cite@styletrue}
\DeclareVoidOption{numbers}{\xynusetup{cite-style=inline}\xynu@legacy@cite@styletrue}
\DeclareVoidOption{authoryear}{\xynusetup{cite-style=authoryear}\xynu@legacy@cite@styletrue}
\DeclareVoidOption{colorlogo}{\xynusetup{badge-color=blue}}
\DeclareVoidOption{bwlogo}{\xynusetup{badge-color=black}}

% 载入 \cls{ctexbook}。
\DeclareDefaultOption{\PassOptionsToClass{\CurrentOption}{ctexbook}}
\ProcessKeyvalOptions*


% \subsection{加载文档类和宏包}

\ifxynu@openright
  \PassOptionsToClass{openright}{book}
\else
  \PassOptionsToClass{openany}{book}
\fi

\ifxynu@output@electronic
  \PassOptionsToClass{oneside}{book}
\fi
\PassOptionsToPackage{no-math}{fontspec}

% 载入 \cls{ctexbook} 文档类，注意要求为 2.4.9 或更高的版本。
\LoadClass[UTF8,a4paper,scheme=plain,zihao=-4,fontset=none]{ctexbook}[2017/04/01]

% 建议在模板开始处载入全部宏包，不要轻易改变加载顺序。
% \pkg{hyperref} 一般在最后加载。
\RequirePackage{etoolbox}
\RequirePackage{amsmath}
\RequirePackage{fontspec}[2017/03/31]
\RequirePackage{geometry}
\RequirePackage{graphicx}
\RequirePackage{fancyhdr}
\RequirePackage{color}
\RequirePackage{titletoc}
\RequirePackage{caption}
\RequirePackage{enumitem}
\RequirePackage[perpage]{footmisc}
\RequirePackage{url}
\RequirePackage{notoccite}
\RequirePackage{multirow}

% 如果用户在导言区未调用 \pkg{biblatex}，则自动调用 \pkg{natbib}。
\AtEndPreamble{
  \@ifpackageloaded{biblatex}{}{
    \RequirePackage{natbib}
  }
}

% 对冲突的宏包报错。
\RequirePackage{filehook}
\newcommand\xynu@package@conflict[2]{
  \AtEndOfPackageFile*{#1}{%
    \AtBeginOfPackageFile*{#2}{%
      \xynu@error{The "#2" package is incompatible with "#1"}%
    }%
  }%
}

\xynu@package@conflict{biblatex}{bibunits}
\xynu@package@conflict{biblatex}{chapterbib}
\xynu@package@conflict{biblatex}{cite}
\xynu@package@conflict{biblatex}{multibib}
\xynu@package@conflict{biblatex}{natbib}

\xynu@package@conflict{bibunits}{biblatex}
\xynu@package@conflict{bibunits}{chapterbib}
\xynu@package@conflict{bibunits}{multibib}

\xynu@package@conflict{unicode-math}{amscd}
\xynu@package@conflict{unicode-math}{amsfonts}
\xynu@package@conflict{unicode-math}{amssymb}
\xynu@package@conflict{unicode-math}{bbm}
\xynu@package@conflict{unicode-math}{bm}
\xynu@package@conflict{unicode-math}{eucal}
\xynu@package@conflict{unicode-math}{eufrak}
\xynu@package@conflict{unicode-math}{mathrsfs}
\xynu@package@conflict{unicode-math}{newtxmath}
\xynu@package@conflict{unicode-math}{upgreek}

\xynu@package@conflict{natbib}{biblatex}
\xynu@package@conflict{natbib}{cite}

\xynu@package@conflict{newtxmath}{amsfonts}
\xynu@package@conflict{newtxmath}{amssymb}
\xynu@package@conflict{newtxmath}{unicode-math}
\xynu@package@conflict{newtxmath}{upgreek}


% \pkg{amsthm} 需要在 \pkg{newtx} 前载入，参考 \pkg{newtx} 的文档。
\AtBeginOfPackageFile*{amsthm}{
  \@ifpackageloaded{newtxmath}{
    \xynu@error{The "amsthm" package should be loaded before setting "newtxmath"}
  }{}
}%



% \subsection{处理语言}

% 定义 \cs{xynu@main@language}，当在导言区修改 \option{language} 时，
% 保存为论文的主要语言；
% \cs{xynu@reset@main@language} 则用于正文中恢复为主要语言。
%    \begin{macrocode}
\xynusetup{main-language=\xynu@language}%
\let\xynu@main@language\xynu@language

\xynu@option@hook{language}{%
  \ifx\@begindocumenthook\@undefined\else
    \xynusetup{main-language=\xynu@language}%
    \let\xynu@main@language\xynu@language
  \fi
}
\newcommand\xynu@reset@main@language{%
  \xynusetup{language = \xynu@main@language}%
  \let\xynu@language\xynu@main@language
}

% 带圈数字和星号使用中文字体。
\ifLuaTeX
  % ctex 将带圈数字 U+2460–U+2473 归入字符范围 3（ALchar），这里改回范围 6（JAchar）
  \ltjdefcharrange{6}{"2460-"2473, "2605}
\else
  \ifXeTeX
    \xeCJKDeclareCharClass{CJK}{"2460 -> "2473, "2605}
  \fi
\fi

% 由于 Unicode 的一些标点符号是中西文混用的：
% U+00B7、U+2013、U+2014、U+2018、U+2019、
% U+201C、U+201D、U+2025、U+2026、U+2E3A，
% 所以要根据语言设置正确的字体。
% https://github.com/CTeX-org/ctex-kit/issues/389
\newcommand\xynu@set@punctuations{%
  \ifxynu@language@chinese
    \ifLuaTeX
      \ltjsetparameter{jacharrange={+9}}
    \else
      \ifXeTeX
        \xeCJKDeclareCharClass{FullLeft}{"2018, "201C}%
        \xeCJKDeclareCharClass{FullRight}{
          "00B7, "2019, "201D, "2013, "2014, "2025, "2026, "2E3A,
        }%
      \fi
    \fi
  \else
    \ifLuaTeX
      \ltjsetparameter{jacharrange={-9}}
    \else
      \ifXeTeX
        \xeCJKDeclareCharClass{HalfLeft}{"2018, "201C}%
        \xeCJKDeclareCharClass{HalfRight}{
          "00B7, "2019, "201D, "2013, "2014, "2025, "2026, "2E3A,
        }%
      \fi
    \fi
  \fi
}
\xynu@set@punctuations
\xynu@option@hook{language}{\xynu@set@punctuations}

% 根据语言设置各章节的名称，只有在导言区设置 \option{language} 时会修改，
% 而在正文局部切换语言时则不变。

% 由于《撰写手册》中的“speciality”一词使用的是英式拼法，
% 所以“acknowledgements”也保持一致。
\newcommand\xynu@set@chapter@names{%
   \ifxynu@main@language@chinese
   \ctexset{
   contentsname = {目\quad 录}
  }
    \def\listfigurename{插图清单}%
    \def\listtablename{附表清单}%
    \def\xynu@list@figure@table@name{插图和附表清单}%
    \ctexset{
      chapter/name   = {第,章},
    }%
    \def\bibname{参考文献}%
    \def\appendixname{附录}%
    \def\xynu@acknowledgements@name{致谢}%
    \def\xynu@achievements@name{攻读学位期间获得与学位论文相关的科研成果目录}%
    \newcommand\xynu@notation@name{主要符号表}%
  \else
    \def\contentsname{Contents}%
    \def\listfigurename{List of Figures}%
    \def\listtablename{List of Tables}%
    \def\xynu@list@figure@table@name{List of Figures and Tables}%
    \ctexset{
      chapter/name   = {\chaptername\space},
    }%
    \def\bibname{Bibliography}%
    \def\appendixname{Appendix}%
    \def\xynu@acknowledgements@name{Acknowledgements}%
    \def\xynu@achievements@name{Research Achievements}%
    \def\xynu@notation@name{Notation}%
  \fi
}
\xynu@set@chapter@names
\xynu@option@hook{main-language}{\xynu@set@chapter@names}

% 这部分名称在正文中局部地修改语言时会发生变化。
\newcommand\xynu@set@names{%
  \ifxynu@language@chinese
    \def\figurename{图}%
    \def\tablename{表}%
  \else
    \def\figurename{Figure}%
    \def\tablename{Table}%
  \fi
}
\xynu@set@names
\xynu@option@hook{language}{\xynu@set@names}


% \subsection{字体}

% 字号

% 正文字号12bp，行距20bp；
% 其他命令的行距按照相同的的比例设置，如表~\ref{tab:fontsize}。
% \begin{table}[htb]
%   \centering
%   \caption{标准字体命令与字号、行距的对应}
%   \label{tab:fontsize}
%   \begin{tabular}{lllll}
%     \toprule
%     字体命令          & 字号 & bp   & 行距 \\
%     \midrule
%     \cs{tiny}         & 小六 & 6.5  & 10.83      \\
%     \cs{scriptsize}   & 六号 & 7.5  & 12.5       \\
%     \cs{footnotesize} & 小五 & 9    & 15         \\
%     \cs{small}        & 五号 & 10.5 & 17.5       \\
%     \cs{normalsize}   & 小四 & 12   & 20         \\
%     \cs{large}        & 小三 & 15   & 25         \\
%     \cs{Large}        & 小二 & 18   & 30         \\
%     \cs{LARGE}        & 二号 & 22   & 36.67      \\
%     \cs{huge}         & 小一 & 24   & 40         \\
%     \cs{Huge}         & 一号 & 26   & 43.33      \\
%     \bottomrule
%   \end{tabular}
% \end{table}
%
% 表达式的行距根据需要采用，段前6磅、段后6磅。
%
% 注意重定义 \normalsize 应在 \pkg{unicode-math} 的 \cs{setmathfont} 前。
\newcommand\xynu@set@font@size{%
  \renewcommand\normalsize{%
    \@setfontsize\normalsize{12bp}{20bp}%
    \abovedisplayskip 6bp \@plus3bp \@minus3bp%
    \abovedisplayshortskip 6bp \@plus3bp \@minus3bp%
    \belowdisplayshortskip \abovedisplayshortskip
    \belowdisplayskip \abovedisplayskip
    \let\@listi\@listI}%
  %
  % 注意第~\ref{sec:list} 节去掉了列表的间距，所以不再修改 \cs{@listi}。
  \normalsize
  \ifx\MakeRobust\@undefined \else
      \MakeRobust\normalsize
  \fi
}
\xynu@set@font@size
\xynu@option@hook{degree}{\xynu@set@font@size}

% 设置行距的倍数为 1。
\linespread{1}\selectfont


% 检测系统
\ifxynu@system@auto
  \IfFileExists{/System/Library/Fonts/Menlo.ttc}{
    \xynusetup{system = mac}
  }{
    \IfFileExists{/dev/null}{
      \IfFileExists{null:}{
        \xynusetup{system = windows}
      }{
        \xynusetup{system = unix}
      }
    }{
      \xynusetup{system = windows}
    }
  }
\fi

% 处理 \opt{fontset}
\ifxynu@fontset@auto
  \ifxynu@system@windows
    \xynusetup{fontset = windows}
  \else
    \IfFontExistsTF{SimSun}{
      \xynusetup{fontset = windows}
    }{
      \ifxynu@system@mac
        \xynusetup{fontset = mac}
      \else
        \IfFontExistsTF{Noto Serif CJK SC}{
          \xynusetup{fontset = ubuntu}
        }{
          \xynusetup{fontset = fandol}
        }
      \fi
    }
  \fi
\fi

% 《撰写手册》要求西文字体使用 Times New Roman 和 Arial，
% 但是在 Linux 下没有这两个字体，所以使用它们的克隆版 TeX Gyre Termes 和
% TeX Gyre Heros。
\ifxynu@font@auto
  \ifxynu@fontset@windows
    \xynusetup{font=times}
  \else
    \ifxynu@fontset@mac
      \xynusetup{font=times}
    \else
      \xynusetup{font=termes}
    \fi
  \fi
\fi

% Times New Roman + Arial
\newcommand\xynu@set@font@times{%
  \setmainfont{Times New Roman}%
  \setsansfont{Arial}%
  \ifxynu@system@mac
    \setmonofont{Menlo}[Scale = MatchLowercase]%
  \else
    \setmonofont{Courier New}[Scale = MatchLowercase]%
  \fi
}

% TeX Gyre Termes
\newcommand\xynu@set@font@termes{%
  \setmainfont{texgyretermes}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-italic,
    BoldItalicFont = *-bolditalic,
  ]%
  \xynu@set@texgyre@sans@mono
}

\newcommand\xynu@set@texgyre@sans@mono{%
  \setsansfont{texgyreheros}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-italic,
    BoldItalicFont = *-bolditalic,
  ]%
  \setmonofont{texgyrecursor}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-italic,
    BoldItalicFont = *-bolditalic,
    Scale          = MatchLowercase,
    Ligatures      = CommonOff,
  ]%
}

% STIX Two 字体。
% STIX 文件名在 v2.10 2020-12-19 从
% \file{STIX2Text-Regular.otf}、\file{STIX2Math.otf} 分别改为
% \file{STIXTwoText-Regular.otf}、\file{STIXTwoMath-Regular.otf}。
\let\xynu@font@family@stix\@empty
\newcommand\xynu@set@stix@names{%
  \ifx\xynu@font@family@stix\@empty
    \IfFontExistsTF{STIXTwoText-Regular.otf}{%
      \gdef\xynu@font@family@stix{STIXTwoText}%
      \gdef\xynu@font@name@stix@math{STIXTwoMath-Regular}%
    }{%
      \gdef\xynu@font@family@stix{STIX2Text}%
      \gdef\xynu@font@name@stix@math{STIX2Math}%
    }%
  \fi
}

\newcommand\xynu@set@font@stix{%
  \xynu@set@stix@names
  \setmainfont{\xynu@font@family@stix}[
    Extension      = .otf,
    UprightFont    = *-Regular,
    BoldFont       = *-Bold,
    ItalicFont     = *-Italic,
    BoldItalicFont = *-BoldItalic,
  ]%
  \xynu@set@texgyre@sans@mono
}

% XITS 字体。
% XITS 的文件名在 v1.109 2018-09-30
% 从 \file{xits-regular.otf}、\file{xits-math.otf} 分别改为
% \file{XITS-Regular.otf}、\file{XITSMath-Regular.otf}。
\let\xynu@font@family@xits\@empty
\newcommand\xynu@set@xits@names{%
  \ifx\xynu@font@family@xits\@empty
    \IfFontExistsTF{XITSMath-Regular.otf}{%
      \gdef\xynu@font@family@xits{XITS}%
      \gdef\xynu@font@style@xits@rm{Regular}%
      \gdef\xynu@font@style@xits@bf{Bold}%
      \gdef\xynu@font@style@xits@it{Italic}%
      \gdef\xynu@font@style@xits@bfit{BoldItalic}%
      \gdef\xynu@font@name@xits@math{XITSMath-Regular}%
    }{%
      \gdef\xynu@font@family@xits{xits}%
      \gdef\xynu@font@style@xits@rm{regular}%
      \gdef\xynu@font@style@xits@bf{bold}%
      \gdef\xynu@font@style@xits@it{italic}%
      \gdef\xynu@font@style@xits@bfit{bolditalic}%
      \gdef\xynu@font@name@xits@math{xits-math}%
    }%
  \fi
}

\newcommand\xynu@set@font@xits{%
  \xynu@set@xits@names
  \setmainfont{\xynu@font@family@xits}[
    Extension      = .otf,
    UprightFont    = *-\xynu@font@style@xits@rm,
    BoldFont       = *-\xynu@font@style@xits@bf,
    ItalicFont     = *-\xynu@font@style@xits@it,
    BoldItalicFont = *-\xynu@font@style@xits@bfit,
  ]%
  \xynu@set@texgyre@sans@mono
}

% Libertinus 的文件名在 v6.7 2019-04-03 从小写改为驼峰式，
% 在大小写敏感的平台上需要进行判断。
\let\xynu@font@family@libertinus\@empty
\newcommand\xynu@set@libertinus@names{%
  \ifx\xynu@font@family@libertinus\@empty
    \IfFontExistsTF{LibertinusSerif-Regular.otf}{%
      \gdef\xynu@font@family@libertinus@serif{LibertinusSerif}%
      \gdef\xynu@font@family@libertinus@sans{LibertinusSans}%
      \gdef\xynu@font@name@libertinus@math{LibertinusMath-Regular}%
      \gdef\xynu@font@style@libertinus@rm{Regular}%
      \gdef\xynu@font@style@libertinus@bf{Bold}%
      \gdef\xynu@font@style@libertinus@it{Italic}%
      \gdef\xynu@font@style@libertinus@bfit{BoldItalic}%
    }{%
      \gdef\xynu@font@family@libertinus@serif{libertinusserif}%
      \gdef\xynu@font@family@libertinus@sans{libertinussans}%
      \gdef\xynu@font@name@libertinus@math{libertinusmath-regular}%
      \gdef\xynu@font@style@libertinus@rm{regular}%
      \gdef\xynu@font@style@libertinus@bf{bold}%
      \gdef\xynu@font@style@libertinus@it{italic}%
      \gdef\xynu@font@style@libertinus@bfit{bolditalic}%
    }%
  \fi
}

\newcommand\xynu@set@font@libertinus{%
  \xynu@set@libertinus@names
  \setmainfont{\xynu@font@family@libertinus@serif}[
    Extension      = .otf,
    UprightFont    = *-\xynu@font@style@libertinus@rm,
    BoldFont       = *-\xynu@font@style@libertinus@bf,
    ItalicFont     = *-\xynu@font@style@libertinus@it,
    BoldItalicFont = *-\xynu@font@style@libertinus@bfit,
  ]%
  \setsansfont{\xynu@font@family@libertinus@sans}[
    Extension      = .otf,
    UprightFont    = *-\xynu@font@style@libertinus@rm,
    BoldFont       = *-\xynu@font@style@libertinus@bf,
    ItalicFont     = *-\xynu@font@style@libertinus@it,
  ]%
  \setmonofont{lmmonolt10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-oblique,
    BoldItalicFont = *-boldoblique,
  ]%
}

% New Computer Modern
\newcommand\xynu@set@font@newcm{%
  \setmainfont{NewCM10}[
    Extension      = .otf,
    UprightFont    = *-Book,
    BoldFont       = *-Bold,
    ItalicFont     = *-BookItalic,
    BoldItalicFont = *-BoldItalic,
  ]%
  \setsansfont{NewCMSans10}[
    Extension         = .otf,
    UprightFont       = *-Book,
    BoldFont          = *-Bold,
    ItalicFont        = *-BookOblique,
    BoldItalicFont    = *-BoldOblique,
  ]%
  \setmonofont{NewCMMono10}[
    Extension           = .otf,
    UprightFont         = *-Book,
    ItalicFont          = *-BookItalic,
    BoldFont            = *-Bold,
    BoldItalicFont      = *-BoldOblique,
  ]%
}

% Latin Modern
\newcommand\xynu@set@font@lm{%
  \setmainfont{lmroman10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-italic,
    BoldItalicFont = *-bolditalic,
  ]%
  \setsansfont{lmsans10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-oblique,
    BoldItalicFont = *-boldoblique,
  ]%
  \setmonofont{lmmonolt10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-oblique,
    BoldItalicFont = *-boldoblique,
  ]%
}

\newcommand\xynu@set@font@newtx{%
  \RequirePackage{newtxtext}%
}

\newcommand\xynu@set@font{%
  \@nameuse{xynu@set@font@\xynu@font}%
}
\xynu@set@font
\xynu@option@hook{font}{\xynu@set@font}

% 中文字体
\ifxynu@cjk@font@auto
  \ifxynu@fontset@mac
    \xynusetup{cjk-font = mac}
  \else
    \ifxynu@fontset@windows
      \xynusetup{cjk-font = windows}
    \else
      \ifxynu@fontset@ubuntu
        \xynusetup{cjk-font = noto}
      \else
        \xynusetup{cjk-font = fandol}
      \fi
    \fi
  \fi
\fi

% Windows 的中易字体。
\newcommand\xynu@set@cjk@font@windows{%
  \setCJKmainfont{SimSun}[
    AutoFakeBold = 3,
    ItalicFont   = KaiTi,
  ]%
  \setCJKsansfont{SimHei}[AutoFakeBold = 3]%
  \setCJKmonofont{FangSong}%
  \setCJKfamilyfont{zhsong}{SimSun}[AutoFakeBold = 3]%
  \setCJKfamilyfont{zhhei}{SimHei}[AutoFakeBold = 3]%
  \setCJKfamilyfont{zhkai}{KaiTi}%
  \setCJKfamilyfont{zhfs}{FangSong}%
}

% macOS 的华文字体。
\newcommand\xynu@set@cjk@font@mac{%
  \defaultCJKfontfeatures{}%
  \setCJKmainfont{Songti SC}[
    UprightFont    = * Light,
    BoldFont       = * Bold,
    ItalicFont     = Kaiti SC Regular,
    BoldItalicFont = Kaiti SC Bold,
  ]%
  \setCJKsansfont{Heiti SC}[
    UprightFont    = * Light,
    BoldFont       = * Medium,
  ]%
  \setCJKmonofont{STFangsong}
  \setCJKfamilyfont{zhsong}{Songti SC}[
    UprightFont    = * Light,
    BoldFont       = * Bold,
  ]%
  \setCJKfamilyfont{zhhei}{Heiti SC}[
    UprightFont    = * Light,
    BoldFont       = * Medium,
  ]%
  \setCJKfamilyfont{zhfs}{STFangsong}%
  \setCJKfamilyfont{zhkai}{Kaiti SC}[
    UprightFont    = * Regular,
    BoldFont       = * Bold,
  ]%
  \setCJKfamilyfont{zhli}{Baoli SC}%
  \setCJKfamilyfont{zhyuan}{Yuanyi SC}[
    UprightFont    = * Light,
    BoldFont       = * Bold,
  ]%
}

% 思源字体。
% 注意 Noto CJK 的 regular 字重名字不带“Regular”。
\newcommand\xynu@set@cjk@font@noto{%
  \defaultCJKfontfeatures{}%
  \setCJKmainfont{Noto Serif CJK SC}[
    UprightFont    = * Light,
    BoldFont       = * Bold,
    ItalicFont     = FandolKai-Regular,
    ItalicFeatures = {Extension = .otf},
    Script         = CJK,
  ]%
  \setCJKsansfont{Noto Sans CJK SC}[
    BoldFont       = * Medium,
    Script         = CJK,
  ]%
  \setCJKmonofont{Noto Sans Mono CJK SC}[
    Script         = CJK,
  ]%
  \setCJKfamilyfont{zhsong}{Noto Serif CJK SC}[
    UprightFont    = * Light,
    UprightFont    = * Bold,
    Script         = CJK,
  ]%
  \setCJKfamilyfont{zhhei}{Noto Sans CJK SC}[
    BoldFont       = * Medium,
    Script         = CJK,
  ]%
  \setCJKfamilyfont{zhfs}{FandolFang}[
    Extension      = .otf,
    UprightFont    = *-Regular,
  ]%
  \setCJKfamilyfont{zhkai}{FandolKai}[
    Extension      = .otf,
    UprightFont    = *-Regular,
  ]%
}

% Fandol 字体。
\newcommand\xynu@set@cjk@font@fandol{%
  \defaultCJKfontfeatures{}%
  \setCJKmainfont{FandolSong}[
    Extension   = .otf,
    UprightFont = *-Regular,
    BoldFont    = *-Bold,
    ItalicFont  = FandolKai-Regular,
    ItalicFeatures = {Extension = .otf},
  ]%
  \setCJKsansfont{FandolHei}[
    Extension   = .otf,
    UprightFont = *-Regular,
    BoldFont    = *-Bold,
  ]%
  \setCJKmonofont{FandolFang}[
    Extension   = .otf,
    UprightFont = *-Regular,
  ]%
  \setCJKfamilyfont{zhsong}{FandolSong}[
    Extension   = .otf,
    UprightFont = *-Regular,
    BoldFont    = *-Bold,
  ]%
  \setCJKfamilyfont{zhhei}{FandolHei}[
    Extension   = .otf,
    UprightFont = *-Regular,
    BoldFont    = *-Bold,
  ]%
  \setCJKfamilyfont{zhfs}{FandolFang}[
    Extension   = .otf,
    UprightFont = *-Regular,
  ]%
  \setCJKfamilyfont{zhkai}{FandolKai}[
    Extension   = .otf,
    UprightFont = *-Regular,
  ]%
}

\ifxynu@cjk@font@none\else
  \providecommand\songti{\CJKfamily{zhsong}}
  \providecommand\heiti{\CJKfamily{zhhei}}
  \providecommand\fangsong{\CJKfamily{zhfs}}
  \providecommand\kaishu{\CJKfamily{zhkai}}
\fi

\newcommand\xynu@set@cjk@font{%
  \@nameuse{xynu@set@cjk@font@\xynu@cjk@font}%
}
\xynu@set@cjk@font
\xynu@option@hook{cjk-font}{\xynu@set@cjk@font}

% 封面标题字体（优先使用华文新魏，缺失时回退到默认中文字体）
\newcommand\xynu@title@font{%
  \ifxynu@cjk@font@none
    \sffamily
  \else
    \CJKfamily{zhsong}%
  \fi
}
\newcommand\xynu@set@title@font{%
  \IfFontExistsTF{STXinwei}{%
    \setCJKfamilyfont{zhxinwei}{STXinwei}%
    \renewcommand\xynu@title@font{\CJKfamily{zhxinwei}}%
  }{%
    \IfFontExistsTF{华文新魏}{%
      \setCJKfamilyfont{zhxinwei}{华文新魏}%
      \renewcommand\xynu@title@font{\CJKfamily{zhxinwei}}%
    }{%
      \xynu@warning{Font HuaWenXinWei (STXinwei) is not available; using default CJK font for title}%
    }%
  }%
}
\xynu@set@title@font
\xynu@option@hook{cjk-font}{\xynu@set@title@font}

% 封面“硕士学位论文”字体（优先使用华文中宋，缺失时回退）
\newcommand\xynu@thesis@name@font{%
  \ifxynu@cjk@font@none
    \sffamily
  \else
    \CJKfamily{zhsong}%
  \fi
}
\newcommand\xynu@set@thesis@name@font{%
  \IfFontExistsTF{STZhongsong}{%
    \setCJKfamilyfont{zhzhongsong}{STZhongsong}%
    \renewcommand\xynu@thesis@name@font{\CJKfamily{zhzhongsong}}%
  }{%
    \IfFontExistsTF{华文中宋}{%
      \setCJKfamilyfont{zhzhongsong}{华文中宋}%
      \renewcommand\xynu@thesis@name@font{\CJKfamily{zhzhongsong}}%
    }{%
      \xynu@warning{Font HuaWenZhongSong (STZhongsong) is not available; using default CJK font for thesis type}%
    }%
  }%
}
\xynu@set@thesis@name@font
\xynu@option@hook{cjk-font}{\xynu@set@thesis@name@font}

% 数学字体

% 设置数学符号风格。
\newcommand\xynu@set@math@style{%
  \ifxynu@math@style@TeX
    \xynusetup{
      uppercase-greek    = upright,
      less-than-or-equal = horizontal,
      integral           = slanted,
      integral-limits    = false,
      partial            = italic,
      math-ellipsis      = AMS,
      real-part          = fraktur,
    }%
  \else
    \xynusetup{
      uppercase-greek = italic,
      integral        = upright,
      partial         = upright,
      real-part       = roman,
    }%
    \ifxynu@math@style@ISO
      \xynusetup{
        less-than-or-equal = horizontal,
        integral-limits    = true,
        math-ellipsis      = lower,
      }%
    \else
      \ifxynu@math@style@GB
        \xynusetup{
          less-than-or-equal = slanted,
          integral-limits    = false,
          math-ellipsis      = centered,
        }%
      \fi
    \fi
  \fi
}

\ifxynu@main@language@chinese
  \xynusetup{math-style = GB}%
\else
  \xynusetup{math-style = TeX}%
\fi

\xynu@set@math@style
\xynu@option@hook{math-style}{\xynu@set@math@style}
\xynu@option@hook{main-language}{%
  \ifxynu@main@language@chinese
    \xynusetup{math-style = GB}%
  \else
    \xynusetup{math-style = TeX}%
  \fi
}

% 针对 \pkg{unicode-math} 逐项配置数学符号。

\newcommand\xynu@set@unimath@leq{%
  \ifxynu@leq@horizontal
    \ifx\@begindocumenthook\@undefined
      \let\le\xynu@save@leq
      \let\ge\xynu@save@geq
      \let\leq\xynu@save@leq
      \let\geq\xynu@save@geq
    \else
      \AtBeginDocument{%
        \let\le\xynu@save@leq
        \let\ge\xynu@save@geq
        \let\leq\xynu@save@leq
        \let\geq\xynu@save@geq
      }%
    \fi
  \else
    \ifxynu@leq@slanted
      \ifx\@begindocumenthook\@undefined
        \let\le\leqslant
        \let\ge\geqslant
        \let\leq\leqslant
        \let\geq\geqslant
      \else
        \AtBeginDocument{%
          \let\le\leqslant
          \let\ge\geqslant
          \let\leq\leqslant
          \let\geq\geqslant
        }%
      \fi
    \fi
  \fi
}
\newcommand\xynu@set@unimath@integral@limits{%
  \ifxynu@integral@limits@true
    \removenolimits{%
      \int\iint\iiint\iiiint\oint\oiint\oiiint
      \intclockwise\varointclockwise\ointctrclockwise\sumint
      \intbar\intBar\fint\cirfnint\awint\rppolint
      \scpolint\npolint\pointint\sqint\intlarhk\intx
      \intcap\intcup\upint\lowint
    }%
  \else
    \addnolimits{%
      \int\iint\iiint\iiiint\oint\oiint\oiiint
      \intclockwise\varointclockwise\ointctrclockwise\sumint
      \intbar\intBar\fint\cirfnint\awint\rppolint
      \scpolint\npolint\pointint\sqint\intlarhk\intx
      \intcap\intcup\upint\lowint
    }%
  \fi
}
\newcommand\xynu@set@unimath@ellipsis{%
  \ifxynu@math@ellipsis@centered
    \DeclareRobustCommand\mathellipsis{\mathinner{\unicodecdots}}%
  \else
    \DeclareRobustCommand\mathellipsis{\mathinner{\unicodeellipsis}}%
  \fi
}
\newcommand\xynu@set@unimath@real@part{%
  \ifxynu@real@part@roman
    \AtBeginDocument{%
      \def\Re{\operatorname{Re}}%
      \def\Im{\operatorname{Im}}%
    }%
  \else
    \AtBeginDocument{%
      \let\Re\xynu@save@Re
      \let\Im\xynu@save@Im
    }%
  \fi
}

\newcommand\xynu@set@unimath@style{%
  \ifxynu@uppercase@greek@upright
    \unimathsetup{math-style = TeX}%
  \else
    \ifxynu@uppercase@greek@italic
      \unimathsetup{math-style = ISO}%
    \fi
  \fi
  \ifxynu@math@style@TeX
    \unimathsetup{bold-style = TeX}%
  \else
    \unimathsetup{bold-style = ISO}%
  \fi
  \xynu@set@unimath@leq
  \xynu@set@unimath@integral@limits
  \ifxynu@partial@upright
    \unimathsetup{partial = upright}%
  \else
    \ifxynu@partial@italic
      \unimathsetup{partial = italic}%
    \fi
  \fi
  \xynu@set@unimath@ellipsis
  \xynu@set@unimath@real@part
}

\newcommand\xynu@qed{\rule{1ex}{1ex}}
\newcommand\xynu@load@unimath{%
  \@ifpackageloaded{unicode-math}{}{%
    \RequirePackage{unicode-math}%
    \AtBeginDocument{%
      \let\xynu@save@leq\leq
      \let\xynu@save@geq\geq
      \let\xynu@save@Re\Re
      \let\xynu@save@Im\Im
    }%
    %
    % 兼容旧的粗体命令：\pkg{bm} 的 \cs{bm} 和 \pkg{amsmath} 的 \cs{boldsymbol}。
    \DeclareRobustCommand\bm[1]{{\symbfit{##1}}}%
    \DeclareRobustCommand\boldsymbol[1]{{\symbfit{##1}}}%
    %
    % 兼容 \pkg{amsfonts} 和 \pkg{amssymb} 中的一些命令。
    \newcommand\square{\mdlgwhtsquare}%
    \newcommand\blacksquare{\mdlgblksquare}%
    \AtBeginDocument{%
      \renewcommand\checkmark{\ensuremath{✓}}%
    }%
    %
    % 兼容 \pkg{amsthm} 的 \cs{qedsymbol}。
    \renewcommand\xynu@qed{\ensuremath{\QED}}%
  }%
}

% STIX Two Math
\newcommand\xynu@set@math@font@stix{%
  \xynu@load@unimath
  \xynu@set@unimath@style
  \xynu@set@stix@names
  \setmathfont{\xynu@font@name@stix@math}[
    Extension    = .otf,
    Scale        = MatchLowercase,
    StylisticSet = \xynu@xits@integral@stylistic@set,
  ]%
  \setmathfont{\xynu@font@name@stix@math}[
    Extension    = .otf,
    Scale        = MatchLowercase,
    StylisticSet = 1,
    range        = {scr,bfscr},
  ]%
}

% XITS Math
\newcommand\xynu@xits@integral@stylistic@set{%
  \ifxynu@integral@upright
    8%
  \fi
}
\newcommand\xynu@set@math@font@xits{%
  \xynu@load@unimath
  \xynu@set@unimath@style
  \xynu@set@xits@names
  \setmathfont{\xynu@font@name@xits@math}[
    Extension    = .otf,
    Scale        = MatchLowercase,
    StylisticSet = \xynu@xits@integral@stylistic@set,
  ]%
  % 使用 STIX Two Math 的 `\mathcal` 字形
  \xynu@set@stix@names
  \setmathfont{\xynu@font@name@stix@math}[
    Extension    = .otf,
    Scale        = MatchLowercase,
    range        = {cal, bfcal},
  ]%
}

% Libertinus Math
\newcommand\xynu@libertinus@integral@stylistic@set{%
  \ifxynu@integral@slanted
    8%
  \fi
}
\newcommand\xynu@set@math@font@libertinus{%
  \xynu@load@unimath
  \xynu@set@unimath@style
  \xynu@set@libertinus@names
  \xynu@set@xits@names
  \setmathfont{\xynu@font@name@libertinus@math}[
    Extension    = .otf,
    StylisticSet = \xynu@libertinus@integral@stylistic@set,
  ]%
  \setmathfont{\xynu@font@name@xits@math}[
    Extension    = .otf,
    range        = {\checkmark},
  ]%
}

% New Computer Modern Math
\newcommand\xynu@newcm@integral@stylistic@set{%
  \ifxynu@integral@upright
    2%
  \fi
}
\newcommand\xynu@set@math@font@newcm{%
  \xynu@load@unimath
  \xynu@set@unimath@style
  \setmathfont{NewCMMath-Book}[
    Extension    = .otf,
    StylisticSet = \xynu@newcm@integral@stylistic@set,
  ]%
  \setmathfont{NewCMMath-Book}[
    Extension    = .otf,
    StylisticSet = 1,
    range        = {scr,bfscr},
  ]%
  \setmathrm{NewCM10}[
    Extension      = .otf,
    UprightFont    = *-Book,
    BoldFont       = *-Bold,
    ItalicFont     = *-BookItalic,
    BoldItalicFont = *-BoldItalic,
  ]%
  \setmathsf{NewCMSans10}[
    Extension         = .otf,
    UprightFont       = *-Book,
    BoldFont          = *-Bold,
    ItalicFont        = *-BookOblique,
    BoldItalicFont    = *-BoldOblique,
  ]%
  \setmathtt{NewCMMono10}[
    Extension           = .otf,
    UprightFont         = *-Book,
    ItalicFont          = *-BookItalic,
    BoldFont            = *-Bold,
    BoldItalicFont      = *-BoldOblique,
  ]%
}

% Latin Modern Math
\newcommand\xynu@set@math@font@lm{%
  \xynu@load@unimath
  \xynu@set@unimath@style
  \setmathfont{latinmodern-math}[Extension=.otf]%
  \setmathrm{lmroman10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-italic,
    BoldItalicFont = *-bolditalic,
  ]%
  \setmathsf{lmsans10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-oblique,
    BoldItalicFont = *-boldoblique,
  ]%
  \setmathtt{lmmonolt10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-oblique,
    BoldItalicFont = *-boldoblique,
  ]%
}

% NewTX Math
% 注意 NewTX Math 是 Type 1 字体，如果正文西文使用了 OpenType 字体时需要小心处理。
\newcommand\xynu@set@math@font@newtx{%
  \ifxynu@font@newtx\else
    \let\xynu@save@encodingdefault\encodingdefault
    \let\xynu@save@rmdefault\rmdefault
    \let\xynu@save@sfdefault\sfdefault
    \let\xynu@save@ttdefault\ttdefault
    \RequirePackage[T1]{fontenc}%
    \renewcommand{\rmdefault}{ntxtlf}%
    \renewcommand{\sfdefault}{qhv}%
    \renewcommand{\ttdefault}{ntxtt}%
  \fi
  \ifxynu@uppercase@greek@italic
    \PassOptionsToPackage{slantedGreek}{newtxmath}%
  \fi
  \ifxynu@integral@upright
    \PassOptionsToPackage{upint}{newtxmath}%
  \fi
  \RequirePackage{newtxmath}
  \let\xynu@save@leq\leq
  \let\xynu@save@geq\geq
  \ifxynu@leq@slanted
    \let\le\leqslant
    \let\ge\geqslant
    \let\leq\leqslant
    \let\geq\geqslant
  \fi
  \ifxynu@integral@limits@true
    \let\ilimits@\displaylimits
  \fi
  \let\xynu@save@partial\partial
  \ifxynu@partial@upright
    \let\partial\uppartial
  \fi
  \ifxynu@math@ellipsis@centered
    \DeclareRobustCommand\mathellipsis{\mathinner{\cdotp\cdotp\cdotp}}%
  \else
    \DeclareRobustCommand\mathellipsis{\mathinner{\ldotp\ldotp\ldotp}}%
  \fi
  \let\xynu@save@Re\Re
  \let\xynu@save@Im\Im
  \ifxynu@real@part@roman
    \def\Re{\operatorname{Re}}%
    \def\Im{\operatorname{Im}}%
  \fi
  \RequirePackage{bm}%
  \ifxynu@font@newtx\else
    \let\encodingdefault\xynu@save@encodingdefault
    \let\rmdefault\xynu@save@rmdefault
    \let\sfdefault\xynu@save@sfdefault
    \let\ttdefault\xynu@save@ttdefault
  \fi
  \DeclareRobustCommand\symup[1]{{\mathrm{##1}}}%
  \DeclareRobustCommand\symbf[1]{{\bm{##1}}}%
  \DeclareRobustCommand\symbfsf[1]{{\bm{##1}}}%
  \let\increment\upDelta%
  \renewcommand\xynu@qed{\openbox}%
}

% Computer Modern
% 使用 LaTeX 默认的 cm 字体
\newcommand\xynu@set@math@font@cm{%
  \RequirePackage{amssymb}
  \let\xynu@save@leq\leq
  \let\xynu@save@geq\geq
  \ifxynu@leq@slanted
    \let\le\leqslant
    \let\ge\geqslant
    \let\leq\leqslant
    \let\geq\geqslant
  \fi
  \ifxynu@integral@limits@true
    \let\ilimits@\displaylimits
  \fi
  \ifxynu@math@ellipsis@centered
    \DeclareRobustCommand\mathellipsis{\mathinner{\cdotp\cdotp\cdotp}}%
  \else
    \DeclareRobustCommand\mathellipsis{\mathinner{\ldotp\ldotp\ldotp}}%
  \fi
  \let\xynu@save@Re\Re
  \let\xynu@save@Im\Im
  \ifxynu@real@part@roman
    \def\Re{\operatorname{Re}}%
    \def\Im{\operatorname{Im}}%
  \fi
  \RequirePackage{bm}%
  \DeclareRobustCommand\symup[1]{{\mathrm{##1}}}%
  \DeclareRobustCommand\symbf[1]{{\bm{##1}}}%
  \DeclareRobustCommand\symbfsf[1]{{\bm{##1}}}%
  \let\increment\Delta
  \renewcommand\xynu@qed{\openbox}%
  \let\uppi\pi
}

% 不设置数学字体，仅提供兼容支持。
\newcommand\xynu@set@math@font@none{%
  \RequirePackage{amssymb}
  \RequirePackage{bm}%
  \DeclareRobustCommand\symup[1]{{\mathrm{##1}}}%
  \DeclareRobustCommand\symbf[1]{{\bm{##1}}}%
  \DeclareRobustCommand\symbfsf[1]{{\bm{##1}}}%
  \let\increment\Delta
  \renewcommand\xynu@qed{\openbox}%
  \let\uppi\pi
}

\newcommand\xynu@set@math@font{%
  \@nameuse{xynu@set@math@font@\xynu@math@font}%
}
\xynu@option@hook{math-font}{\g@addto@macro\xynu@setup@hook{\xynu@set@math@font}}
\newcommand\xynu@set@math@font@auto{%
  \ifxynu@math@font@auto
    \xynusetup{math-font=xits}%
  \fi
}
\AtBeginOfPackageFile*{siunitx}{\xynu@set@math@font@auto}
\AtEndPreamble{%
  \xynu@set@math@font@auto
  \ifx\square\@undefined
    \RequirePackage{amssymb}%
  \fi
}



% \subsection{纸张和页面}
% 使用 \pkg{geometry} 宏包设置纸张和页面。

% 纸张：A4；

% 纸张大小：标准A4（21.0cm×29.7cm）尺寸。
% 页边距：上、下、左、右、装订线的页边距分别为：2.54cm，2.54cm，3.17cm，3.17cm，0cm。装订线位置：左。左右对称页边距。
% 页眉距边界 2.0cm
% 页脚距边界 1.5cm
% headheight 为 14.65 bp ≈ 0.49 cm（这是一个为了容纳“五号字”并防止报错的“安全高度”。），headsep 为 2.54 - 1.5 - 0.49 = 0.55 cm。
% \geometry{
%  paper      = a4paper,
%  vmargin    = 2.54cm,
%  hmargin    = 3.17cm,
%  headheight = 0.49cm,
%  headsep    = 0.55cm,
%  footskip   = 0.79cm,
% }
\geometry{
  paper      = a4paper,
  % vmargin = {上边距, 下边距}
  vmargin    = {3.5cm, 3.5cm}, 
  % hmargin = {左边距, 右边距}
  hmargin    = {2.8cm, 3.0cm},
  headheight = 0.49cm,
  headsep    = 0.31cm,
  footskip   = 0.8cm,
}

% \geometry{
%   paper      = a4paper,
%   % vmargin = {上边距, 下边距}
%   vmargin    = {3.5cm, 3.5cm}, 
%   % hmargin = {左边距, 右边距}
%   hmargin    = {2.8cm, 3.0cm},
  
%   % --- 2. 设置页眉位置 ---
%   % 逻辑：上边距(3.5) - 页眉距顶(2.7) = 剩下 0.8cm 给页眉和缝隙
%   headheight = 0.5cm,  % 设定页眉高度约为 14pt (防止报错)
%   headsep    = 0.3cm,  % 剩余的缝隙 (0.8 - 0.5 = 0.3)
  
%   % --- 3. 设置页脚位置 ---
%   % 逻辑：下边距(3.5) - 页脚距底(2.7) = 0.8cm
%   footskip   = 0.8cm,
% }
% 使用 \pkg{fancy} 需要先调用 |\pagestyle{fancy}| 再修改 \cs{chaptermark} 和
% \cs{sectionmark}。
\newif\ifxynu@show@header
\xynu@show@headerfalse
\pagestyle{fancy}
\let\sectionmark\@gobble
\renewcommand\headrulewidth{\ifxynu@show@header 0.75bp\else 0pt\fi}

% 重定义默认的 |plain| page style，会显示页眉和页脚。
\fancypagestyle{plain}{%
  \fancyhf{}%
  %
  % 页眉与该部分的章标题相同，宋体 10.5 磅（五号）居中。
  % 页码：宋体 10.5 磅、页面下脚居中。
  \def\xynu@hf@font{\fontsize{10.5bp}{13.65bp}\selectfont}
  % \fancyhead[C]{\xynu@hf@font\leftmark}%
  \fancyhead[C]{\xynu@hf@font\ifxynu@show@header 信阳师范大学硕士学位论文\fi}%
  \fancyfoot[C]{\xynu@hf@font\thepage}%
  \let\@mkboth\markboth
  \def\chaptermark##1{%
    \markboth{\CTEXifname{\CTEXthechapter\quad}{}##1}{}%
  }%
  \let\sectionmark\@gobble
}
\pagestyle{plain}

% 设置特殊的 page style 不改变任何内容，用于每章首页。
\def\ps@chapter{}
\ctexset{chapter/pagestyle=chapter}

% 空白页不需加页眉（包括页眉线），但需有连续编的页码。
\fancypagestyle{blank}{%
  \fancyhf{}%
  \renewcommand\headrulewidth{0pt}%
  \fancyfoot[C]{\xynu@hf@font\thepage}%
}

\newif\ifxynu@title@page

\def\cleardoublepage{%
  \clearpage
  \if@twoside
    \ifodd\c@page\else
      \hbox{}%
      \ifxynu@title@page
        % 封面的空白页不显示页码
        \thispagestyle{empty}%
      \else
        \thispagestyle{blank}%
      \fi
      \newpage
      \if@twocolumn
        \hbox{}%
        \newpage
      \fi
    \fi
  \fi
}

%
% 从“中文摘要”开始页码用大写罗马数字。
\renewcommand\frontmatter{%
  \cleardoublepage
  \@mainmatterfalse
  \xynu@show@headerfalse
  \pagenumbering{Roman}%
  \pagestyle{plain}%
}

\renewcommand\mainmatter{%
  \cleardoublepage
  \pagenumbering{arabic}%
  \pagestyle{plain}%
  \@mainmattertrue
  \xynu@show@headertrue
}

\g@addto@macro\appendix{\@mainmattertrue}%


% \subsection{封面}


% 定义用户接口：
\xynu@define@key{
  title = {
    default = {论文题目},
  },
  title* = {
    default = {Title},
    name    = title@en,
  },
  author = {
    default = {学位申请人姓名},
  },
  author* = {
    default = {Candidate},
    name    = author@en,
  },
  speciality = {
    default = {专业学位领域},
  },
  speciality* = {
    default = {Speciality},
    name    = speciality@en,
  },
  supervisor = {
    default = {导师},
  },
  supervisor* = {
    default = {Supervisor Name},
    name    = supervisor@en,
  },
  practice-supervisor = {
    default = {},
    name    = practice@supervisor,
  },
  practice-supervisor* = {
    default = {},
    name    = practice@supervisor@en,
  },
  advisor = {
    name    = practice@supervisor,
  },
  advisor* = {
    name    = practice@supervisor@en,
  },
  date = {
    default = {\the\year-\two@digits{\month}-\two@digits{\day}},
  },
  professional-type = {
    name = professional@type,
  },
  professional-type* = {
    name = professional@type@en,
  },
  department,
  department* = {
    name    = department@en,
    default = {},
  },
  university* = {
    name    = university@en,
    default = {Xinyang Normal University, Xinyang, China},
  },
  classification-number = {
    name = classification@number,
  },
  school-code = {
    name    = school@code,
    default = {10477},
  },
  student-id = {
    name = student@id,
  },
  secret-level = {
    name    = secret@level,
  },
  secret-level* = {
    name    = secret@level@en,
  },
  keywords,
  keywords* = {
    name    = keywords@en,
  },
}

% 导师一栏可能有多个姓名，所以用 \opt{supervisor} 进行收集，
% 然后使用本命令来输出要求的格式，
% 类似于 \LaTeX3 的 \cs{clist\_use:Nn}。
\newcommand\xynu@clist@count[1]{%
  \csname clist_count:N\endcsname{#1}%
}
\newcommand\xynu@clist@use[2]{%
  \csname clist_use:Nn\endcsname{#1}{#2}%
}
\newcommand\xynu@supervisor@names{%
  \xynu@clist@use{\xynu@supervisor}{\quad}
}
\newcommand\xynu@practice@supervisor@names{%
  \xynu@clist@use{\xynu@practice@supervisor}{\quad}
}
\newcounter{xynu@count}
\newcommand\xynu@supervisor@en@line{%
  \setcounter{xynu@count}{\xynu@clist@count{\xynu@supervisor@en}}%
  \ifnum\c@xynu@count>1\relax
    Supervisors:%
  \else
    Supervisor:%
  \fi
  \space\xynu@clist@use{\xynu@supervisor@en}{, }%
}
\newcommand\xynu@practice@supervisor@en@line{%
  \setcounter{xynu@count}{\xynu@clist@count{\xynu@practice@supervisor@en}}%
  \ifnum\c@xynu@count>1\relax
    Practice supervisors:%
  \else
    Practice supervisor:%
  \fi
  \space\xynu@clist@use{\xynu@practice@supervisor@en}{, }%
}

% % 输出日期的给定格式：\cs{xynu@format@date}\marg{format}\marg{date}，
% % 其中格式 \meta{format} 接受三个参数分别对应年、月、日，
% % \meta{date} 是 ISO 格式的日期（yyyy-mm-dd）。
% \newcommand\xynu@format@date[2]{%
%   \edef\xynu@@date{#2}%
%   \def\xynu@@process@date##1-##2-##3\@nil{%
%     #1{##1}{##2}{##3}%
%   }%
%   \expandafter\xynu@@process@date\xynu@@date\@nil
% }
% \newcommand\xynu@date@format@zh@small[3]{\number#1 年 \number#2 月 \number#3 日}
% % 使用阿拉伯数字日期（替代中文大写）
% \newcommand\xynu@date@format@zh@big[3]{\number#1 年 \number#2 月 \number#3 日}
% \newcommand\xynu@date@month[1]{%
%   \ifcase\number#1\or
%     January\or February\or March\or April\or May\or June\or
%     July\or August\or September\or October\or November\or December%
%   \fi
% }
% \newcommand\xynu@date@format@zh@short[3]{\number#1 年 \number#2 月}
% \newcommand\xynu@date@format@en[3]{\xynu@date@month{#2} \number#3, #1}
% \newcommand\xynu@date@zh@small{\xynu@format@date{\xynu@date@format@zh@small}{\xynu@date}}
% \newcommand\xynu@date@zh@big{\xynu@format@date{\xynu@date@format@zh@big}{\xynu@date}}
% \newcommand\xynu@date@zh@short{\xynu@format@date{\xynu@date@format@zh@short}{\xynu@date}}
% \newcommand\xynu@date@en{\xynu@format@date{\xynu@date@format@en}{\xynu@date}}


% 输出日期的给定格式：\cs{xynu@format@date}\marg{format}\marg{date}，
% 其中格式 \meta{format} 接受三个参数分别对应年、月、日，
% \meta{date} 是 ISO 格式的日期（yyyy-mm-dd）。
\newcommand\xynu@format@date[2]{%
  \edef\xynu@@date{#2}%
  \def\xynu@@process@date##1-##2-##3\@nil{%
    #1{##1}{##2}{##3}%
  }%
  \expandafter\xynu@@process@date\xynu@@date\@nil
}

% 【修改点 1】去掉 #3 和“日”，只保留年月
\newcommand\xynu@date@format@zh@small[3]{\number#1 年 \number#2 月}

% 【修改点 2】去掉 #3 和“日”，只保留年月
% 使用阿拉伯数字日期（替代中文大写）
\newcommand\xynu@date@format@zh@big[3]{\number#1 年 \number#2 月}

\newcommand\xynu@date@month[1]{%
  \ifcase\number#1\or
    January\or February\or March\or April\or May\or June\or
    July\or August\or September\or October\or November\or December%
  \fi
}

% 短格式原本就是只显示年月，保持不变
\newcommand\xynu@date@format@zh@short[3]{\number#1 年 \number#2 月}

% 【修改点 3】去掉 #3 和逗号，英文格式变为 "Month Year"
\newcommand\xynu@date@format@en[3]{\xynu@date@month{#2} #1}

\newcommand\xynu@date@zh@small{\xynu@format@date{\xynu@date@format@zh@small}{\xynu@date}}
\newcommand\xynu@date@zh@big{\xynu@format@date{\xynu@date@format@zh@big}{\xynu@date}}
\newcommand\xynu@date@zh@short{\xynu@format@date{\xynu@date@format@zh@short}{\xynu@date}}
\newcommand\xynu@date@en{\xynu@format@date{\xynu@date@format@en}{\xynu@date}}


% 版本 v3.2 开始使用 \cs{xynusetup} 设置接口，
% 兼容旧版本的命令式设置。
% Deprecated since 2020-07-01.
\def\xynu@define@term#1#2{%
  \expandafter\gdef\csname #1\endcsname##1{%
    \xynu@deprecated{'\expandafter\protect\csname #1\endcsname' command}{2020-07-01}{'\protect\xynusetup'}%
    \xynusetup{#2 = {##1}}%
  }%
}
\xynu@define@term{title}{title}
\xynu@define@term{entitle}{title*}
\xynu@define@term{author}{author}
\xynu@define@term{enauthor}{author*}
\xynu@define@term{major}{speciality}
\xynu@define@term{enmajor}{speciality*}
\xynu@define@term{supervisor}{supervisor}
\xynu@define@term{ensupervisor}{supervisor*}
\gdef\cosupervisor#1{%
  \g@addto@macro\xynu@supervisor{, #1}%
}
\gdef\encosupervisor#1{%
  \g@addto@macro\xynu@supervisor@en{, #1}%
}
\gdef\date#1{\renewcommand\xynu@date@zh@big{#1}}
\gdef\endate#1{\renewcommand\xynu@date@en{#1}}
\xynu@define@term{professionaltype}{professional-type}
\xynu@define@term{enprofessionaltype}{professional-type*}
\xynu@define@term{secretlevel}{secret-level}
\xynu@define@term{ensecretlevel}{secret-level*}
\gdef\keywords#1{\renewcommand\xynu@keywords@text{#1}}
\gdef\enkeywords#1{\renewcommand\xynu@keywords@en@text{#1}}

% 定义一些常量（硕士学位）。
\newcommand\xynu@thesis@name{硕士学位论文}
\newcommand\xynu@thesis@name@en{A dissertation for master's degree}
\newcommand\xynu@degree@category{硕士学位}
\ifxynu@degree@type@academic
\else
  \ifxynu@degree@type@professional
    \renewcommand\xynu@thesis@name{专业硕士学位论文}
    \renewcommand\xynu@degree@category{工程师硕士}
    \renewcommand\xynu@thesis@name@en{A Dissertation Submitted for the Degree of Master}
  \else
    \ifxynu@degree@type@engineering
      \renewcommand\xynu@thesis@name{工程硕士学位论文}
      \renewcommand\xynu@degree@category{工程硕士学位}
    \fi
  \fi
  \IfFontExistsTF{LiSu}{
    \setCJKfamilyfont{zhli}{LiSu}
    \providecommand\lishu{\CJKfamily{zhli}}
  }{
    \ifxynu@cjk@font@mac
      \providecommand\lishu{\CJKfamily{zhli}}
    \else
      \providecommand\lishu{%
        \xynu@warning{Font LiSu is not available}%
        \sffamily
      }
    \fi
  }
\fi

% 定义校徽颜色
%
% 推迟定义颜色以避免调用 \pkg{xcolor} 时的警告
\AtBeginDocument{
  \definecolor{xynublue}{cmyk}{1,0.8,0,0}
}

% 添加 PDF 书签，在 \pkg{hyperref} 载入后才有效。
\newcommand\xynu@pdfbookmark{\@gobble}

% 重定义 \env{titlepage} 环境，不修改页码。
\renewenvironment{titlepage}{%
  \cleardoublepage
  \if@twocolumn
    \@restonecoltrue\onecolumn
  \else
    \@restonecolfalse\newpage
  \fi
  \thispagestyle{empty}%
}{%
  \if@restonecol\twocolumn \else \newpage \fi
}

% 中文封面（硕士）：版式与内容输出入口。
% 说明：
% - 内容字段来自 \xynusetup（见 xynusetup.tex），如 title/author/speciality/supervisor 等。
% - 封面图片在 figures/ 目录，位置用 \vspace/\hspace 调整，尺寸用 \includegraphics 的 height/width 控制。
% - 标题字体由 \xynu@title@font 控制（已设置为华文新魏优先），字号/行距在标题处设置。
%
% 样式参考：
% 密级仿宋 14 磅；
% 论文类型黑体 56 磅；
% 论文题目黑体 26 磅加粗居中，单倍行距；
% 作者姓名宋体 16 磅，1.5 倍行距；
\newlength\xynu@cover@top@field@width
\newlength\xynu@cover@top@label@left@width
\newlength\xynu@cover@top@label@right@width
\newlength\xynu@cover@top@left@width
\newlength\xynu@cover@top@right@width
\newlength\xynu@cover@badge@height
\newlength\xynu@cover@badge@width
\setlength{\xynu@cover@top@field@width}{6em}
\setlength{\xynu@cover@badge@height}{3.57cm}
\setlength{\xynu@cover@badge@width}{3.66cm}
% Top info block fonts (classification/school code/secret/student-id).
\newcommand\xynu@cover@top@label@font{%
  \ifxynu@cjk@font@none
    \bfseries\fontsize{12bp}{18bp}\selectfont
  \else
    \songti\bfseries\fontsize{12bp}{18bp}\selectfont
  \fi
}
\newcommand\xynu@cover@top@value@font{%
  \ifxynu@cjk@font@none
    \bfseries\fontsize{12bp}{18bp}\selectfont
  \else
    \songti\bfseries\fontsize{12bp}{18bp}\selectfont
  \fi
}
% Underlined field for the top info block.
\newcommand\xynu@cover@top@field[2][\xynu@cover@top@field@width]{%
  \underline{\hb@xt@ #1{\hss#2\hss}}%
}
\newlength\xynu@cover@label@width
% Width of the right-hand field column for underline layout.
\newlength\xynu@cover@field@width
% Cover table justification (both edges).
\newcommand\xynu@cover@justify{%
  \leftskip=0pt\relax
  \rightskip=0pt\relax
  \parfillskip=0pt\relax
}
% Cover label/value fonts for the info block.
\newcommand\xynu@cover@label@font{%
  \ifxynu@cjk@font@none
    \bfseries\fontsize{14bp}{21bp}\selectfont
  \else
    \songti\bfseries\fontsize{14bp}{21bp}\selectfont
  \fi
}
\newcommand\xynu@cover@value@font{%
  \xynu@title@font\fontsize{15bp}{22.5bp}\selectfont
}
% Underlined field with left-aligned content (form-style line).
\newcommand\xynu@cover@field[1]{%
  \underline{\hb@xt@ \xynu@cover@field@width{\hss#1\hss}}%
}
\newcommand\xynu@title@page@graduate@zh{%
  \xynusetup{language=chinese}%
  \begin{titlepage}%
    % PDF 书签标题（可改成别的封面名称）
    \xynu@pdfbookmark{封面}%
    \centering
    % 将顶部信息块上移，使其与页眉分界线位置对齐
    \vspace*{-6\headsep}%
    % 顶部信息块：分类号/密级/学校代码/学号
    \parbox[t]{\textwidth}{%
      \settowidth{\xynu@cover@top@label@left@width}{\xynu@cover@top@label@font 分类号}%
      \settowidth{\xynu@cover@top@label@right@width}{\xynu@cover@top@label@font 学校代码}%
      \setlength{\xynu@cover@top@left@width}{\dimexpr\xynu@cover@top@label@left@width+\xynu@cover@top@field@width+0.8em\relax}%
      \setlength{\xynu@cover@top@right@width}{\dimexpr\xynu@cover@top@label@right@width+\xynu@cover@top@field@width+0.8em\relax}%
      \begin{tabular*}{\textwidth}{@{}c@{\extracolsep{\fill}}c@{\extracolsep{\fill}}c@{}}
        \parbox[c][\xynu@cover@badge@height][c]{\xynu@cover@top@left@width}{%
          \begin{tabular}[c]{@{}>{\xynu@cover@justify\xynu@cover@top@label@font}p{\xynu@cover@top@label@left@width}@{\hspace{0.8em}}>{\xynu@cover@top@value@font}p{\xynu@cover@top@field@width}@{}}
            分类号 & \xynu@cover@top@field{\xynu@classification@number} \\
            密级 & \xynu@cover@top@field{\xynu@secret@level}
          \end{tabular}%
        }%
        &
        \parbox[c][\xynu@cover@badge@height][c]{\xynu@cover@badge@width}{%
          \centering
          % 校徽居中放在顶部；调节尺寸请改 \xynu@cover@badge@height/\xynu@cover@badge@width
          \begingroup
            \ifxynu@badge@color@blue
              \color{xynublue}%
            \fi
            \includegraphics[height=\xynu@cover@badge@height,width=\xynu@cover@badge@width,keepaspectratio]{figures/xynu-badge.jpg}%
          \endgroup
        }%
        &
        \parbox[c][\xynu@cover@badge@height][c]{\xynu@cover@top@right@width}{%
          \begin{tabular}[c]{@{}>{\xynu@cover@justify\xynu@cover@top@label@font}p{\xynu@cover@top@label@right@width}@{\hspace{0.8em}}>{\xynu@cover@top@value@font}p{\xynu@cover@top@field@width}@{}}
            学校代码 & \xynu@cover@top@field{\xynu@school@code} \\
            学号 & \xynu@cover@top@field{\xynu@student@id}
          \end{tabular}%
        }%
      \end{tabular*}%
    }\par
    \vspace*{26.5bp}%
    % 校名书法图片：调整 \vspace 上下位置，height 控制大小
    \vspace{10bp}%
    \includegraphics[height=2.14cm,width=11.57cm,keepaspectratio]{figures/xynu-name-stxingkai.pdf}\par
    \vspace{-7bp}%
    \begingroup
      % “硕士学位论文”字样：字号/行距可改，字距用 CJKglue/kanjiskip 微调
      \xynu@thesis@name@font\fontsize{40bp}{40bp}\selectfont
      %字间距”控制
      \ifLuaTeX
        \ltjsetparameter{kanjiskip = {-5.2bp}}%只在LuaTeX下生效，日文/中文字符之间的默认间距。设成负值会把字挤近，正值会拉开。

      \else
        \renewcommand\CJKglue{\hspace{1.5bp}}%%在非 LuaTeX（通常是 XeTeX + CJK 宏包）下生效会把字挤紧
      \fi
      %段前/段后间距
      \vspace{\baselineskip}%
      %\vspace{-5bp}%
      \xynu@thesis@name\par
      %\vspace{\baselineskip}%
    \endgroup
    % 专业/工程学位类型（\xynusetup{professional-type=...}）
    \parbox[t][0bp][t]{\textwidth}{%
      \fontsize{26bp}{33.8bp}\selectfont
      \ifx\xynu@professional@type\@empty
        \null
      \else
        \lishu （\xynu@professional@type ）%
      \fi
    }\par
    \vspace{-15bp}%
    % 封面论文标题：字号/行距在此改；字体由 \xynu@title@font 控制
    \parbox[t][101.3bp][c]{\textwidth}{%
      \centering\xynu@title@font\bfseries\linespread{1}\fontsize{30bp}{50bp}\selectfont
      \xynu@title
    }\par
    % 信息块（作者/导师/日期等）：缩进与宽度用 \hspace/\parbox 宽度调整
    \vspace{30bp}%把数值加大信息块就会整体下移。
    \parbox[t]{\textwidth}{%
      \hspace{45bp}%
      \parbox[t]{368bp}{%
        % 左侧标签：宋体四号加粗；右侧：华文新魏小三号
        % 各字段对应的 \xynusetup 键如下（可改标签文本，也可增删行）
        % 标签列两端对齐，冒号对齐；右侧为带下划线的填写区
        % 若标签文案变长，请同步更新这里的“最长标签”测量
        \settowidth{\xynu@cover@label@width}{\xynu@cover@label@font 校外导师姓名、职称：}%
        \setlength{\xynu@cover@field@width}{\dimexpr368bp-\xynu@cover@label@width-1em\relax}%
        \renewcommand\arraystretch{1.3}%
        \begin{tabular}{@{}>{\xynu@cover@justify\xynu@cover@label@font}p{\xynu@cover@label@width}@{\hspace{1em}}>{\xynu@cover@value@font}p{\xynu@cover@field@width}@{}}
          学位申请人姓名： & \xynu@cover@field{\xynu@author} \\
          申请学位类别： & \xynu@cover@field{\xynu@degree@category} \\
          专业学位领域： & \xynu@cover@field{\xynu@speciality} \\
          校内导师姓名、职称： & \xynu@cover@field{\xynu@supervisor@names} \\
          校外导师姓名、职称： & \xynu@cover@field{\xynu@practice@supervisor@names} \\
          所属院（系、所）： & \xynu@cover@field{\xynu@department} \\
          论文提交日期： & \xynu@cover@field{\xynu@date@zh@big} \\
        \end{tabular}%
      }%
    }%
  \end{titlepage}%
  \xynu@reset@main@language
}

% 英文封面：字段来自 title*/author*/speciality*/supervisor* 等
\newcommand\xynu@title@page@graduate@en{%
  \xynusetup{language=english}%
  \begin{titlepage}%
    \xynu@pdfbookmark{Title page}%
    \centering
    
    % 英文题名：Times New Roman，小二加粗，居中，单倍行距
    \vspace{-40bp}%
    \begingroup
      \rmfamily\bfseries\fontsize{18bp}{30bp}\selectfont
      \xynu@title@en\par
    \endgroup
    % 学位论文类型（英文）：三号字，居中，单倍行距（A Dissertation Submitted for the Degree of Master）
    \vspace{60bp}%
    \begingroup
      \rmfamily\fontsize{16bp}{16bp}\selectfont
      \xynu@thesis@name@en\par
    \endgroup
    % 英文信息块：三号字，居中，首字符左对齐
    % \vspace{52bp}%
    % \begingroup
    %   \rmfamily\bfseries\fontsize{16bp}{16bp}\selectfont
    %   \renewcommand\arraystretch{1.0}%
    %   \setlength{\tabcolsep}{0pt}%
    %   \makebox[\textwidth][c]{%
    %     \parbox{0.7\textwidth}{%
    %       \raggedright
    %       \begin{tabular}{@{}l@{\hspace{0em}}l@{}}
    %         Candidate: & \xynu@author@en \\
    %         Supervisor: & \xynu@clist@use{\xynu@supervisor@en}{, } \\
    %         \ifx\xynu@practice@supervisor@en\@empty\else
    %           Co-Supervisor: & \xynu@clist@use{\xynu@practice@supervisor@en}{, } \\
    %         \fi
    %       \end{tabular}%
    %     }%
    %   }\par
    % \endgroup
    % 英文信息块：三号字，整体居中，内部左对齐
% 英文信息块
\vspace{100bp}%
\begingroup
  \rmfamily\bfseries\fontsize{16bp}{16bp}\selectfont
  \renewcommand\arraystretch{1}%
  
  % 【关键步骤1】把表格默认的列间距清零
  \setlength{\tabcolsep}{0pt}%
  
  \makebox[\textwidth][c]{%
    % 此时表格列定义里不需要 @{\hspace...} 了，因为我们要在下面手动加
    \begin{tabular}{@{} l l @{}}
    
      % 【关键步骤2】在每一行的 & 后面，单独写 \hspace{数值} 来控制这一行的距离
      
      % 第1行：Candidate 距离名字 1em
      Candidate:      & \hspace{-1em}\xynu@author@en \\[50bp] 
      
      % 第2行：Supervisor 距离名字 1em (你可以改成 2em, 0.5cm 等任意值)
      Supervisor:     & \hspace{-1em}\xynu@clist@use{\xynu@supervisor@en}{, }\\[50bp] 
      
      \ifx\xynu@practice@supervisor@en\@empty\else
        % 第3行：Co-Supervisor 距离名字 1em (也可以单独改)
        Co-Supervisor:  & \hspace{0.5em}\xynu@clist@use{\xynu@practice@supervisor@en}{, } \\
      \fi
      
    \end{tabular}%
  }\par
\endgroup
    % 学院英文名称 + 学校英文名
    \vspace{50bp}%
    \begingroup
      \rmfamily\fontsize{16bp}{30bp}\selectfont
      \ifx\xynu@department@en\@empty\else
        \xynu@department@en\par
      \fi
      \xynu@university@en\par
    \endgroup

  \end{titlepage}%
  \xynu@reset@main@language
}

% 重新定义 \cs{maketitle}，调用 \cs{xynu@makezhtitle}, \cs{xynu@makeentitle}
% 分别生成中、英文封面。
\renewcommand\maketitle{%
  \pagenumbering{Alph}%
  \pagestyle{empty}%
  \xynu@title@pagetrue
  \xynu@title@page@graduate@zh
  \xynu@title@page@graduate@en
  \cleardoublepage
  \restoregeometry
  \pagestyle{plain}%
  \xynu@title@pagefalse
}


% \subsection{原创性声明}

% 定义原创性声明
\newcommand\xynu@originality{%
 本人声明，所呈交的论文是本人在导师指导下进行的研究工作及取
得的研究成果。尽我所知，除了文中特别加以标注和致谢的地方外，论
文中不包含其他人已经发表或撰写过的研究成果，也不包含为获得信阳
师范大学或其他教育机构的学位或证书而使用过的材料。与我一同工作
的同志对本研究所做的任何贡献均已在论文中作了明确的说明并表示
了谢意。}
\newcommand\xynu@authorization{%
  本人完全了解信阳师范大学有关保留、使用学位论文的规定，即学
校有权保留并向国家有关部门或机构送交论文的复印件和电子版，允许
论文被查阅和借阅。本人授权信阳师范大学可以将本学位论文的全部内
容编入有关数据库进行检索，可以采用影印、缩印或其他复制手段保存
或汇编本学位论文。同时授权经信阳师范大学认可的国家有关机构或论
文数据库使用或收录本学位论文，并向社会公众提供信息服务。\par
 {\centering （保密的论文在解密后应遵守此规定）\par}%
 }

% 生成空的下划线
\newcommand\xynu@underline[2][8em]{\underline{\hb@xt@ #1{\hss#2\hss}}}

\newcommand\xynu@checkbox{%
  \makebox[0bp][l]{\raisebox{-0.2ex}{\hspace{0.1em}$\checkmark$}}%
  $\square$%
}
%原创性和授权使用声明格式修改
% \newcommand\copyrightpage{%
%   \begin{titlepage}%
%     \xynu@pdfbookmark{原创性和授权使用声明}%
%     \vspace*{21bp}%
%     {\centering\heiti\fontsize{18bp}{28bp}\selectfont
%       中国科学技术大学学位论文原创性声明\par}%
%     \vspace{13bp}%
%     \begingroup
%       \ifLuaTeX
%         \ltjsetparameter{kanjiskip = {0bp plus .1pt minus .1pt}}%
%       \else
%         \renewcommand\CJKglue{\hspace{0bp plus .1pt minus .1pt}}%
%       \fi
%       \CJKfamily{zhzhongsong}\fontsize{14bp}{28bp}\selectfont
%       \xynu@originality\par
%     \endgroup
%     \vspace{37bp}%
%     \noindent
%     作者签名：\xynu@underline{}\hspace{8em}%
%     签字日期：\xynu@underline{}\par
%     \vspace{69bp}%
%     {\centering\heiti\fontsize{18bp}{28bp}\selectfont
%       中国科学技术大学学位论文授权使用声明\par}%
%     \vspace{13bp}%
%     \begingroup
%       \ifLuaTeX
%         \ltjsetparameter{kanjiskip = {0bp plus .1pt minus .1pt}}%
%       \else
%         \renewcommand\CJKglue{\hspace{0bp plus .1pt minus .1pt}}%
%       \fi
%       \CJKfamily{zhzhongsong}\fontsize{14bp}{28bp}\selectfont
%       \xynu@authorization\par
%     \endgroup
%     \vspace{10bp}%
%     \noindent
%     作者签名：\xynu@underline[7.5em]{}\hspace{8.5em}%
%     导师签名：\xynu@underline[7.5em]{}\par
%     \vspace{1em}%
%     \noindent
%     签字日期：\xynu@underline[7.5em]{}\hspace{8.5em}%
%     签字日期：\xynu@underline[7.5em]{}\par
%   \end{titlepage}%
%   \xynu@title@pagetrue
%   \cleardoublepage
%   \xynu@title@pagefalse
% }
% 原创性和授权使用声明格式修改
\newcommand\copyrightpage{%
  \begin{titlepage}%
    \xynu@pdfbookmark{原创性和授权使用声明}%
    
    % --- 第一部分：独创性声明 ---
    \vspace{0bp}%
    {\centering\heiti\fontsize{18bp}{28bp}\selectfont
     % 修改标题为分散对齐，模仿图片中的间距
     \makebox[7em][s]{独创性声明}\par}% 
    \vspace{13bp}%
    
    \begingroup
      \ifLuaTeX
        \ltjsetparameter{kanjiskip = {0bp plus .1pt minus .1pt}}%
      \else
        \renewcommand\CJKglue{\hspace{0bp plus .1pt minus .1pt}}%
      \fi
      \CJKfamily{zhzhongsong}\fontsize{14bp}{28bp}\selectfont
      \xynu@originality\par
    \endgroup
  
    % --- 上半部分：独创性声明 ---
    \vspace{50bp}%
    \noindent
    {\CJKfamily{zhzhongsong}%
      \hspace{11em}签\quad 名：\hspace{3em}% 把 \xynu@underline 改为 \hspace
     \hspace{4em} % 
      % 日期部分也全改为 \hspace
      日\quad 期：\hspace{1.5em}年\hspace{1em}月\hspace{1em}日%
    }\hspace{2em}\par
    
    % --- 第二部分：授权书 ---
    \vspace{60bp}%
    {\centering\heiti\fontsize{18bp}{28bp}\selectfont
      学位论文使用授权书\par}%
    \vspace{13bp}%
    
    \begingroup
      \ifLuaTeX
        \ltjsetparameter{kanjiskip = {0bp plus .1pt minus .1pt}}%
      \else
        \renewcommand\CJKglue{\hspace{0bp plus .1pt minus .1pt}}%
      \fi
      \CJKfamily{zhzhongsong}\fontsize{14bp}{28bp}\selectfont
      % 这里假设 \xynu@authorization 内部已经包含了居中的“(保密的论文...)”
      \xynu@authorization\par
    \endgroup

    \vspace{30bp}%
    \noindent
    {\CJKfamily{zhzhongsong}%
      \hspace{1em}%
      % 三处签名/日期全改为 \hspace，保持原来的宽度数值
      研究生（签名）：\hspace{4em}%
      \hfill
      导师（签名）：\hspace{5em}%
      \hfill
      日期：\hspace{1.5em}年\hspace{1em}月\hspace{1em}日%
    }\hspace{1em}\par

  \end{titlepage}%
  \xynu@title@pagetrue
  \cleardoublepage
  \xynu@title@pagefalse
}



% Deprecated since 2020-07-01.
\newcommand\makestatement{%
  \xynu@deprecated{'\protect\makestatement' command}{2020-07-01}{'\protect\copyrightpage'}%
  \copyrightpage
}


% \subsection{章节标题}

% 硕士论文一般不建议使用三级节标题，不得使用三级以下节标题。
\setcounter{secnumdepth}{3}

% 五级节标题和脚注需要使用带圈的数字，这里使用 \cs{xynu@circlefont} ：
\newcommand\xynu@textcircled[1]{%
  \ifnum\value{#1}<21\relax
    {\symbol{\numexpr\value{#1} + "245F\relax}}%
  \else
    \xynu@error{Cannot display more than 20 footnotes}%
  \fi
}

% 用 \pkg{ctex} 的接口设置全部章节标题格式。
%章节编号使用ArialBlack 字体（仅作用于编号）。
\newfontfamily\xynu@heading@numberfont{Arial Black}
% 各章标题，例如：“第1章  引言”。
% 章序号采用阿拉伯数字，章序号与标题之间空一个汉字符，采用黑体三号字，居中书写，单倍行距，段前24磅，段后24磅。
% 摘要、目录和列于目录中与章平级的其它部分的标题（如参考文献、附录、致谢等）也用这同一种格式。
% 由于 LaTeX 的排版方式与 Word 不同，为了效果与 Word 模板一致，
\ctexset{
  chapter = {
    format      = \centering\heiti\bfseries\fontsize{16bp}{20bp}\selectfont,
    nameformat  = {},
    titleformat = {},
    number      = \thechapter,
        % 【修改点】添加 numberformat，指定数字使用 Arial Black
    numberformat = \xynu@heading@numberfont, 
    aftername   = \quad,
    beforeskip  = 24bp,
    afterskip   = 24bp,
    lofskip      = 0pt,
    lotskip      = 0pt,
    % fixskip     = true,
  },
}

% 一级节标题，例如：“2.1  实验方法”。
% 节编号用阿拉伯数字表示，前边数字为上级章节的序号，后一数字为本节的顺序号。
% 数字间用半角小数点“.”连接。
% 节标题序号与标题名之间空一个汉字符（下同）。
% 采用黑体四号（14pt）字居左书写，固定行距20磅，段前24磅，段后6磅。
\ctexset{
  section = {
    format     = \heiti\fontsize{14bp}{20bp}\selectfont,
    numberformat = \xynu@heading@numberfont, 
    aftername  = \quad,
    beforeskip = 18bp,
    afterskip  = 18bp,
  },
  %
  % 二级节标题，例如：“2.1.1  实验装置”。
  % 采用黑体13pt字居左书写，固定行距20磅，段前12磅，段后6磅。
  subsection = {
    format     = \heiti\fontsize{13bp}{20bp}\selectfont,
    numberformat = \xynu@heading@numberfont, 
    aftername  = \quad,
    beforeskip = 12bp,
    afterskip  = 12bp,
  },
  %
  % 三级节标题，例如：“2.1.1.1  实验结果”。
  % 采用黑体小四号（12pt）字居左书写，固定行距20磅，段前12磅，段后6磅。
  subsubsection = {
    format     = \heiti\fontsize{12bp}{20bp}\selectfont,
    numberformat = \xynu@heading@numberfont, 
    aftername  = \quad,
    beforeskip = 6bp,
    afterskip  = 6bp,
  },
  %
}%

% 默认的 \cs{chapter*} 生成的章标题没有编号、不更改页眉，
% 也不添加进目录或 PDF 书签。
% 然而像摘要、目录、符号说明这样的章节，它们不需要编号、不加入目录，
% 但是需要修改页眉，并且加入 PDF 标签。
% 所以我们新定义 \cs{xynu@chapter} 用于处理这些章节。%
\NewDocumentCommand\xynu@chapter{o m}{%
  \if@openright\cleardoublepage\else\clearpage\fi
  \IfValueTF{#1}{%
    \xynu@pdfbookmark{#1}%
    \chaptermark{#1}%
  }{%
    \xynu@pdfbookmark{#2}%
    \chaptermark{#2}%
  }%
  \chapter*{#2}}


% \subsection{摘要}

% 中文摘要环境。
\newcommand\xynu@keywords@text{%
  \xynu@clist@use{\xynu@keywords}{；}%
}
\newcommand\xynu@keywords@en@text{%
  \xynu@clist@use{\xynu@keywords@en}{, }%
}
% \newenvironment{abstract}{%
%   \xynusetup{language=chinese}%
%   \xynu@chapter{摘要}%
% }{
%   \par\null\par
%   \setlength\hangindent{4em}%
%   \noindent
%   \textbf{关键词：}\xynu@keywords@text\par
%   \xynu@reset@main@language
% }
% 中文摘要环境（修改版）
\newenvironment{abstract}{%
  \xynusetup{language=chinese}%
  % ==================================================
  % 此处开始单独定义中文摘要的格式
  % ==================================================
  \ctexset{
    chapter = {
      % format: 控制对齐(居中)、加粗、字号(16bp约等于三号字)、行距
      format = \centering\heiti\bfseries\fontsize{16bp}{24bp}\selectfont, 
      % beforeskip: 标题上方的间距
      beforeskip = 0bp,
      % afterskip: 标题下方的间距
      afterskip = 0bp,
      % name = {,}, % 如果不想显示“第一章”字样（视具体类文档设定而定）
      % number = \false, % 确保不编号
    }
  }%
  % ==================================================
  % \xynu@chapter{摘\quad 要}%
  %\addcontentsline{toc}{chapter}{{摘\quad 要}}%
   % 使用 \texorpdfstring 分离两种内容（这个格式是为了解决警告⚠️，但不影响编译），与上面效果看着一致（可选）
    \xynu@chapter{\texorpdfstring{摘\quad 要}{摘要}}
    \addcontentsline{toc}{chapter}{\texorpdfstring{摘\quad 要}{摘要}}%
  
  
}{
  \par
  \setlength\hangindent{4em}%
  \noindent
  \textbf{关键词：}\xynu@keywords@text\par
  \xynu@reset@main@language
}
\newbox\xynu@keywords@box
\newlength\xynu@keywords@width

% 英文摘要环境
\newenvironment{abstract*}{%
  \xynusetup{language=english}%
  \ctexset{
    chapter = {
      format = \centering\bfseries\fontsize{16bp}{24bp}\selectfont,
      beforeskip =0bp,
      afterskip = 0bp,
    }
  }%
  \xynu@chapter{Abstract}%
  \addcontentsline{toc}{chapter}{Abstract}%
  \ctexset{autoindent = 2em}%
}{
  \par
  \setlength\hangindent{6.5em}%
  \noindent
  \textbf{Keyword}:\space
  \xynu@keywords@en@text\par
  \xynu@reset@main@language
}

% Deprecated since 2020-07-01.
\newenvironment{enabstract}{%
  \xynu@deprecated{'enabsctract' environment}{2020-07-01}{'abstract*'}%
  \begin{abstract*}%
}{%
  \end{abstract*}%
}


% \subsection{目录}

% 目录另面起。
\renewcommand\tableofcontents{%
  \xynu@chapter{\contentsname}%
  \@starttoc{toc}%
}

% 下面用 \pkg{titletoc} 宏包设置目录内容的格式。
% 先定义目录线：
\newcommand\xynu@leaders{%
  \hspace{2bp}%
  \titlerule*[4bp]{.}%
  \hspace{2bp}%
}
%%目录条目排版（新加）固定行距 23 磅
\newcommand\xynu@toc@size{%
  \fontsize{12bp}{23bp}\selectfont
}
\newcommand\xynu@toc@chapter@font{%
  \heiti\bfseries\xynu@toc@size%目录章标题加粗，但是页码也跟着变粗了
}
\newcommand\xynu@toc@section@font{%
  \songti\xynu@toc@size
}
\newcommand\xynu@toc@pagefont{%
  \IfFontExistsTF{Times New Roman}{\fontspec{Times New Roman}}{\fontspec{texgyretermes}}%
}

\contentsmargin{0bp}

% 目录中的章标题行采用黑体小四号字，固定行距 23 磅，段前 0 磅，段后 0 磅；
% 其他内容采用宋体小四号字，行距 23 磅，段前、段后均为 0 磅。
% 章标题行居左书写，一级节标题行缩进 1 个汉字符，二级节标题行缩进 2 个汉字符。
% 带有序号的各级标题，其序号与题名之间均空一字符，行末右顶格。
\titlecontents{chapter}
  [0bp]{\addvspace{0bp}\xynu@toc@chapter@font}
  {\contentspush{\thecontentslabel\quad}}{}
  %{\bfseries\xynu@leaders\thecontentspage}
 % {\xynu@leaders\xynu@toc@pagefont\thecontentspage} % 页码用 Times New Roman
  % 在下面这一行增加了 \mdseries，强制取消加粗
  {\xynu@leaders\mdseries\xynu@toc@pagefont\thecontentspage}
  
\titlecontents{section}
  [1em]{\xynu@toc@section@font}
  {\contentspush{\thecontentslabel\quad}}{}
  {\xynu@leaders\xynu@toc@pagefont\thecontentspage}
\titlecontents{subsection}
  [2em]{\xynu@toc@section@font}
  {\contentspush{\thecontentslabel\quad}}{}
  {\xynu@leaders\xynu@toc@pagefont\thecontentspage}

% 处理章节起始页样式与目录。
\renewcommand\chapter{%
  \if@openright\cleardoublepage\else\clearpage\fi
  \thispagestyle{\CTEX@chapter@pagestyle}%
  \global\@topnum\z@
  \@afterindenttrue
  \secdef\@chapter\@schapter
}

% 插图和附表清单
\titlecontents{figure}
  [0bp]{}
  {\contentspush{\figurename~\thecontentslabel\quad}}{}
  {\xynu@leaders\thecontentspage}

\titlecontents{table}
  [0bp]{}
  {\contentspush{\tablename~\thecontentslabel\quad}}{}
  {\xynu@leaders\thecontentspage}

\renewcommand\listoffigures{%
  \xynu@chapter{\listfigurename}%
  \@starttoc{lof}%
}

\renewcommand\listoftables{%
  \xynu@chapter{\listtablename}%
  \@starttoc{lot}%
}

\newcommand\listoffiguresandtables{%
  \xynu@chapter{\xynu@list@figure@table@name}%
  \@starttoc{lof}%
  \@starttoc{lot}%
}


% \subsection{符号说明}

% 研究生规定符号说明另页起，标题字体字号等同论文正文，
\newenvironment{notation}{%
  \xynu@chapter{\xynu@notation@name}%
}{}%

\newcommand*\notationlabel[1]{#1\hfil}%
\newenvironment{notationlist}[1]{%
  \list{}{%
    \itemsep 3bp%
    \labelwidth #1\relax%
    \labelsep 1em%
    \leftmargin\labelwidth
    \advance\leftmargin\labelsep
    \advance\leftmargin 3em%
    \rightmargin 3em%
    \let\makelabel\notationlabel
  }%
}{%
  \endlist
}


% \subsection{正文}

% \cs{sloppy} 可以减少“overfull boxes”。
\sloppy

% 禁止扩大段间距。（\href{https://github.com/xynutug/xynuthesis/issues/209}{
%   xynutug/xynuthesis\#209}）
\raggedbottom

% 段间距 0 磅。
\setlength{\parskip}{0bp}

% 首段缩进。
\ctexset{autoindent=2}

% 首段缩进。
\let\@afterindentfalse\@afterindenttrue
\@afterindenttrue

% URL 的字体设为保持原样。
\urlstyle{same}

% 使用 \pkg{xurl} 宏包的方法，增加 URL 可断行的位置。
\def\UrlBreaks{%
  \do\/%
  \do\a\do\b\do\c\do\d\do\e\do\f\do\g\do\h\do\i\do\j\do\k\do\l%
     \do\m\do\n\do\o\do\p\do\q\do\r\do\s\do\t\do\u\do\v\do\w\do\x\do\y\do\z%
  \do\A\do\B\do\C\do\D\do\E\do\F\do\G\do\H\do\I\do\J\do\K\do\L%
     \do\M\do\N\do\O\do\P\do\Q\do\R\do\S\do\T\do\U\do\V\do\W\do\X\do\Y\do\Z%
  \do0\do1\do2\do3\do4\do5\do6\do7\do8\do9\do=\do/\do.\do:%
  \do\*\do\-\do\~\do\'\do\"\do\-}
\Urlmuskip=0mu plus 0.1mu

% 脚注用带圈的数字：
%\renewcommand\thefootnote{\xynu@textcircled{footnote}}

% 脚注用带圈的数字：
\renewcommand\thefootnote{\arabic{footnote}}

% LaTeX 默认脚注按章计数，即每章的开始才重置脚注计数器；我们修改为按页计数。
% 简单的|\@addtoreset{footnote}{page}|并不可靠，
% \footnote{\url{https://texfaq.org/FAQ-footnpp.html}}
% 所以我们使用 \pkg{footmisc} 宏包。

% 脚注线长为版心宽度的四分之一：
\renewcommand\footnoterule{%
  \kern-3\p@
  \hrule\@width.25\textwidth
  \kern2.6\p@}
  %
  % 注文缩进两字：
\renewcommand\@makefntext[1]{%
  \parindent=2em\relax
  \noindent
  \hb@xt@ 2em{\hss\@makefnmark}#1}


% \subsection{列表}
% \label{sec:list}

% 调整列表中各项之间过大的间距。
\setlength\partopsep{0bp}
\newcommand\xynu@nolistsep{%
  \parsep 0\p@ \@plus.2\p@
  \topsep 0\p@ \@plus.2\p@
  \itemsep0\p@ \@plus.2\p@
}
\def\@listi{\leftmargin\leftmargini
            \xynu@nolistsep}
\let\@listI\@listi
\@listi
\def\@listii {\leftmargin\leftmarginii
              \labelwidth\leftmarginii
              \advance\labelwidth-\labelsep
              \xynu@nolistsep}
\def\@listiii{\leftmargin\leftmarginiii
              \labelwidth\leftmarginiii
              \advance\labelwidth-\labelsep
              \xynu@nolistsep}


% \subsection{浮动体}

% 图题采用宋体，字号 10.5pt，居中书写，单倍行距，段前6磅，段后0磅，
% 图序与图名之间空一个汉字符，

% 表题置于表的上方，采用宋体，加粗，字号11pt，居中书写，单倍行距，段前6磅，段后0磅。
% 表序与表名之间空一个汉字符。

% 使用 \pkg{caption} 宏包设置图、表的格式：
\DeclareCaptionFont{xynu}{\xynu@caption@font}
\newcommand\xynu@caption@font{%
  \ifxynu@language@chinese
    \fontsize{10.5bp}{14.3bp}\selectfont
  \else
    \fontsize{10.5bp}{12.65bp}\selectfont
  \fi
}

\captionsetup{
  justification  = centerlast,
  font           = xynu,
  labelsep       = quad,
  skip           = 6bp,
  figureposition = bottom,
  tableposition  = top,
}

%图标 图题字体加粗
%\captionsetup{font+=bf}

% 若有英文图题，另起一行置于中文图题下方。
\AtBeginOfPackageFile*{bicaption}{
  \let\captionmainlanguage\xynu@main@language
}
\AtEndOfPackageFile*{bicaption}{
  \captionsetup[bi-first]{lang = chinese}
  \captionsetup[bi-second]{
    lang = english,
    list = off,
  }
  \renewcommand\selectcaptionlanguage[2]{%
    \xynusetup{language = #2}%
  }
}

% 表单元格中的文字采用 11pt 宋体字，单倍行距，段前3磅，段后3磅。
% 对于中文，`\arraystretch` 需要设为 1 + (3pt + 3pt) / (11pt * 1.3) ~= 1.42。
% 对于英文，`\arraystretch` 需要设为 1 + (3pt + 3pt) / (11pt * 1.15) ~= 1.47。
%
\newcommand\xynu@table@font{%
  \ifxynu@language@chinese
    \fontsize{11bp}{14.3bp}\selectfont
    \renewcommand\arraystretch{1.42}%
  \else
    \fontsize{11bp}{12.65bp}\selectfont
    \renewcommand\arraystretch{1.47}%
  \fi
}

\patchcmd\@floatboxreset{%
  \normalsize
}{%
  \xynu@table@font
}{}{\xynu@patch@error{\@floatboxreset}}

% 对 \pkg{longtable} 跨页表格进行相同的设置。
\AtEndOfPackageFile*{longtable}{
  \AtBeginEnvironment{longtable}{%
    \ifdim\f@size pt > 11bp\relax
      \xynu@table@font
    \fi
  }
}

% 图注、表注使用 `\figurenote` 或 `\tablenote` 命令，与 `apa7.cls` 一致。
% 图注采用宋体 11pt，单倍行距，段前6磅，段后0磅。
% 多个图注则须顺序编号，注序左缩进2字，与注文之间空一字符，续行悬挂缩进左对齐，两端对齐。
\let\xynu@figure@note@font\xynu@caption@font

\newcommand\figurenote[1]{%
  \begingroup
    \captionsetup{
      font = xynu,
      margin = {2em, 0pt},
      oneside,
    }%
    \caption*{#1}
  \endgroup
}
\let\tablenote\figurenote

% 兼容旧版的 `\note` 命令。
\newcommand\note[1]{%
  \xynu@deprecated{'\protect\note' command}{2025-01-05}{'\protect\figurenote'}%
  \figurenote{#1}%
}

% 设置 \pkg{threeparttable} 表注的默认字号。
\AtEndOfPackageFile*{threeparttable}{
  \AtBeginEnvironment{tablenotes}{%
    \xynu@figure@note@font
  }
}

% 不宜将多个插图连续排版，插图与文字论述段落应穿插排版。

% 修改默认的浮动体描述符为 |h|。
\def\fps@figure{h}
\def\fps@table{h}

% \LaTeX{} 对放置浮动体的要求比较强，这里按照 UK TeX FAQ 的建议
% \footnote{\url{https://texfaq.org/FAQ-floats}} 对其适当放宽。
\renewcommand\topfraction{.85}
\renewcommand\bottomfraction{.7}
\renewcommand\textfraction{.15}
\renewcommand\floatpagefraction{.66}
\renewcommand\dbltopfraction{.66}
\renewcommand\dblfloatpagefraction{.66}
\setcounter{topnumber}{9}
\setcounter{bottomnumber}{9}
\setcounter{totalnumber}{20}
\setcounter{dbltopnumber}{9}

% 插图前后与文字段落之间须留有10磅空行。
% 插图如果不得不与其它插图或表格连续排版，则它们之间须留有20磅空行。
\setlength{\floatsep}{20bp}
\setlength{\textfloatsep}{10bp}
\setlength{\intextsep}{10bp}

% 由于 LaTeX2e kernel 的问题，图表等浮动体与文字前后的距离不一致，需要进行 patch。
% 参考 \href{https://github.com/tuna/thuthesis/issues/614}{tuna/thuthesis/issues\#614}、
% \url{https://www.zhihu.com/question/46618031} 和
% \url{https://tex.stackexchange.com/a/40363/82731}。
%    \begin{macrocode}
\patchcmd{\@addtocurcol}%
  {\vskip \intextsep}%
  {\edef\save@first@penalty{\the\lastpenalty}\unpenalty
   \ifnum \lastpenalty = \@M  % hopefully the OR penalty
     \unpenalty
   \else
     \penalty \save@first@penalty \relax % put it back
   \fi
   \ifnum\outputpenalty <-\@Mii
     \addvspace\intextsep
     \vskip\parskip
   \else
     \addvspace\intextsep
   \fi}%
  {}{\xynu@patch@error{\@addtocurcol}}
\patchcmd{\@addtocurcol}%
  {\vskip\intextsep \ifnum\outputpenalty <-\@Mii \vskip -\parskip\fi}%
  {\ifnum\outputpenalty <-\@Mii
     \aftergroup\vskip\aftergroup\intextsep
     \aftergroup\nointerlineskip
   \else
     \vskip\intextsep
   \fi}%
  {}{\xynu@patch@error{\@addtocurcol}}
\patchcmd{\@getpen}{\@M}{\@Mi}
  {}{\xynu@patch@error{\@getpen}}


% \subsection{表达式}

% 修改 `amsmath` 的 `\tagform@`
% \def\tagform@#1{\maketag@@@{(\ignorespaces#1\unskip\@@italiccorr)}}
\def\tagform@#1{%
  \ifxynu@language@chinese
    \ifxynu@eqn@paren@style@full
      % 这里的 `\unskip` 是为了 `式~\eqref` 不产生额外的空格。
      \unskip
      % \kern 0pt 防止中文左括号与前面文字的距离过窄
      \maketag@@@{\kern 0pt\relax （\ignorespaces#1\unskip\@@italiccorr）}%
    \else
      \maketag@@@{(\ignorespaces#1\unskip\@@italiccorr)}%
    \fi
  \else
    \maketag@@@{(\ignorespaces#1\unskip\@@italiccorr)}%
  \fi
}

% \subsection{参考文献}

% 控制同一个参考文献不跨页.
\AtBeginEnvironment{thebibliography}{\interlinepenalty=10000}


\PassOptionsToPackage{compress}{natbib}

\AtEndOfPackageFile*{natbib}{
  % 定义几种引用文献的标注样式。
  \newcommand\bibstyle@super{\bibpunct{[}{]}{,}{s}{,}{\textsuperscript{,}}}
  \newcommand\bibstyle@inline{\bibpunct{[}{]}{,}{n}{,}{,}}
  \newcommand\bibstyle@authoryear{\bibpunct{(}{)}{;}{a}{,}{,}}
  \@namedef{bibstyle@author-year}{\bibstyle@authoryear}
  %
  % 几种引用样式，与 \file{bst} 文件名保持一致，
  % 这样在使用 \cs{bibliographystyle} 选择参考文献表的样式时也会设置对应的引用样式。
  \@namedef{bibstyle@xynuthesis-numerical}{\bibstyle@super}
  \@namedef{bibstyle@xynuthesis-authoryear}{\bibstyle@authoryear}
  %
  % 如果载入 `natbib` 前设置了 `cite-style`，这里先进行配置。
  % https://github.com/xynutug/xynuthesis/issues/327
  \ifx\xynu@cite@style\@empty\else
    \citestyle{\xynu@cite@style}%
  \fi
  %
  % 定义接口 cite-style 切换引用样式。
  \xynu@option@hook{cite-style}{%
    \citestyle{\xynu@cite@style}%
  }
  %
  % 如果文献序号作为叙述文字的一部分，需要临时将文献序号与正文平排
  \DeclareRobustCommand\inlinecite{\@inlinecite}
  \def\@inlinecite#1{\begingroup\let\@cite\NAT@citenum\citep{#1}\endgroup}
  %
  % 参考文献列表格式：宋体（5号） 10.5 磅，行距 17 磅，续行缩进两字，左对齐。
  \renewcommand\bibfont{%
    \fontsize{10.5bp}{17bp}\selectfont
  }
  %设置参考文献列表中，每一条文献之间的垂直间距。
  %\setlength{\bibsep}{0\p@ \@plus.2\p@}
  \setlength{\bibsep}{3bp}
  
  % 参考文献表的编号居左。
  \renewcommand\@biblabel[1]{[#1]\hfill}
  % 顺序编码制悬挂缩进 2.5 字符
  \renewcommand\NAT@bibsetnum[1]{%
    % \settowidth\labelwidth{\@biblabel{#1}}%
    % \setlength{\leftmargin}{\labelwidth}%
    % \addtolength{\leftmargin}{\labelsep}%
    \setlength{\leftmargin}{2.5em}%
    \setlength{\itemindent}{0pt}%
    \setlength{\labelsep}{0pt}%
    \setlength{\labelwidth}{2.5em}%
    \setlength{\itemsep}{\bibsep}
    \setlength{\parsep}{\z@}%
    \ifNAT@openbib
      \addtolength{\leftmargin}{\bibindent}%
      \setlength{\itemindent}{-\bibindent}%
      \setlength{\listparindent}{\itemindent}%
      \setlength{\parsep}{0pt}%
    \fi
  }
  % 著者-出版年制悬挂缩进 2 字。注意这个宽度是加载时设置的，不能使用 em。
  \setlength{\bibhang}{21bp}
  %
  % 修改引用的样式。
  % 这里在 filehook 中无法使用 \cs{patchcmd}，所以只能手动重定义。
  %
  % 将 super 式 \cs{citep} 引用的页码置于括号外。
  \renewcommand\NAT@citesuper[3]{%
    \ifNAT@swa
      \if*#2*\else
        #2\NAT@spacechar
      \fi
      % \unskip\kern\p@\textsuperscript{\NAT@@open#1\NAT@@close}%
      %  \if*#3*\else\NAT@spacechar#3\fi\else #1\fi\endgroup}
      \unskip\kern\p@
      \textsuperscript{%
        \NAT@@open#1\NAT@@close
        \if*#3*\else#3\fi
      }%
      \kern\p@
    \else
      #1%
    \fi
    \endgroup
  }
  %
  % 将 numbers 式 \cs{citep} 引用的页码置于括号外并改为上标。
  \renewcommand\NAT@citenum[3]{%
    \ifNAT@swa
      \NAT@@open
      \if*#2*\else
        #2\NAT@spacechar
      \fi
      % #1\if*#3*\else\NAT@cmt#3\fi\NAT@@close
      #1\NAT@@close
      \if*#3*\else
        \textsuperscript{#3}%
      \fi
    \else
      #1%
    \fi
    \endgroup
  }
  %
  % 在 filehook 中无法使用 \cs{patchcmd}，所以只能手动重定义。
  \def\NAT@citexynum[#1][#2]#3{%
    \NAT@reset@parser
    \NAT@sort@cites{#3}%
    \NAT@reset@citea
    \@cite{\def\NAT@num{-1}\let\NAT@last@yr\relax\let\NAT@nm\@empty
      \@for\@citeb:=\NAT@cite@list\do
      {\@safe@activestrue
      \edef\@citeb{\expandafter\@firstofone\@citeb\@empty}%
      \@safe@activesfalse
      \@ifundefined{b@\@citeb\@extra@b@citeb}{%
        {\reset@font\bfseries?}
          \NAT@citeundefined\PackageWarning{natbib}%
        {Citation `\@citeb' on page \thepage \space undefined}}%
      {\let\NAT@last@num\NAT@num\let\NAT@last@nm\NAT@nm
        \NAT@parse{\@citeb}%
        \ifNAT@longnames\@ifundefined{bv@\@citeb\@extra@b@citeb}{%
          \let\NAT@name=\NAT@all@names
          \global\@namedef{bv@\@citeb\@extra@b@citeb}{}}{}%
        \fi
        \ifNAT@full\let\NAT@nm\NAT@all@names\else
          \let\NAT@nm\NAT@name\fi
        \ifNAT@swa
        \@ifnum{\NAT@ctype>\@ne}{%
          \@citea
          \NAT@hyper@{\@ifnum{\NAT@ctype=\tw@}{\NAT@test{\NAT@ctype}}{\NAT@alias}}%
        }{%
          \@ifnum{\NAT@cmprs>\z@}{%
          \NAT@ifcat@num\NAT@num
            {\let\NAT@nm=\NAT@num}%
            {\def\NAT@nm{-2}}%
          \NAT@ifcat@num\NAT@last@num
            {\@tempcnta=\NAT@last@num\relax}%
            {\@tempcnta\m@ne}%
          \@ifnum{\NAT@nm=\@tempcnta}{%
            \@ifnum{\NAT@merge>\@ne}{}{\NAT@last@yr@mbox}%
          }{%
            \advance\@tempcnta by\@ne
            \@ifnum{\NAT@nm=\@tempcnta}{%
              % 在顺序编码制下，\pkg{natbib} 只有在三个以上连续文献引用才会使用连接号，
              % 这里修改为允许两个引用使用连接号。
              % 参考 https://tex.stackexchange.com/a/86991/82731 。
              %
              % \ifx\NAT@last@yr\relax
              %   \def@NAT@last@yr{\@citea}%
              % \else
              %   \def@NAT@last@yr{--\NAT@penalty}%
              % \fi
              \def@NAT@last@yr{-\NAT@penalty}%
            }{%
              \NAT@last@yr@mbox
            }%
          }%
          }{%
          \@tempswatrue
          \@ifnum{\NAT@merge>\@ne}{\@ifnum{\NAT@last@num=\NAT@num\relax}{\@tempswafalse}{}}{}%
          \if@tempswa\NAT@citea@mbox\fi
          }%
        }%
        \NAT@def@citea
        \else
          \ifcase\NAT@ctype
            \ifx\NAT@last@nm\NAT@nm \NAT@yrsep\NAT@penalty\NAT@space\else
              \@citea \NAT@test{\@ne}\NAT@spacechar\NAT@mbox{\NAT@super@kern\NAT@@open}%
            \fi
            \if*#1*\else#1\NAT@spacechar\fi
            \NAT@mbox{\NAT@hyper@{{\citenumfont{\NAT@num}}}}%
            \NAT@def@citea@box
          \or
            \NAT@hyper@citea@space{\NAT@test{\NAT@ctype}}%
          \or
            \NAT@hyper@citea@space{\NAT@test{\NAT@ctype}}%
          \or
            \NAT@hyper@citea@space\NAT@alias
          \fi
        \fi
      }%
      }%
        \@ifnum{\NAT@cmprs>\z@}{\NAT@last@yr}{}%
        \ifNAT@swa\else
          % 将 numerical 式 \cs{citet} 引用的页码置于括号外并改为上标。
          %
          % \@ifnum{\NAT@ctype=\z@}{%
          %   \if*#2*\else\NAT@cmt#2\fi
          % }{}%
          \NAT@mbox{\NAT@@close}%
          \@ifnum{\NAT@ctype=\z@}{%
            \if*#2*\else
              \textsuperscript{#2}%
            \fi
          }{}%
          \NAT@super@kern
        \fi
    }{#1}{#2}%
  }%
  %
  % 将 author-year 式 \cs{citep} 引用的页码置于括号外并改为上标：
  \renewcommand\NAT@cite%
      [3]{\ifNAT@swa\NAT@@open\if*#2*\else#2\NAT@spacechar\fi
          % #1\if*#3*\else\NAT@cmt#3\fi\NAT@@close\else#1\fi\endgroup}
          #1\NAT@@close\if*#3*\else\textsuperscript{#3}\fi\else#1\fi\endgroup}
  %
  % 调整 author-year 式 \cs{citet} 引用的页码。
  \def\NAT@citex%
    [#1][#2]#3{%
    \NAT@reset@parser
    \NAT@sort@cites{#3}%
    \NAT@reset@citea
    \@cite{\let\NAT@nm\@empty\let\NAT@year\@empty
      \@for\@citeb:=\NAT@cite@list\do
      {\@safe@activestrue
      \edef\@citeb{\expandafter\@firstofone\@citeb\@empty}%
      \@safe@activesfalse
      \@ifundefined{b@\@citeb\@extra@b@citeb}{\@citea%
        {\reset@font\bfseries ?}\NAT@citeundefined
                  \PackageWarning{natbib}%
        {Citation `\@citeb' on page \thepage \space undefined}\def\NAT@date{}}%
      {\let\NAT@last@nm=\NAT@nm\let\NAT@last@yr=\NAT@year
        \NAT@parse{\@citeb}%
        \ifNAT@longnames\@ifundefined{bv@\@citeb\@extra@b@citeb}{%
          \let\NAT@name=\NAT@all@names
          \global\@namedef{bv@\@citeb\@extra@b@citeb}{}}{}%
        \fi
      \ifNAT@full\let\NAT@nm\NAT@all@names\else
        \let\NAT@nm\NAT@name\fi
      \ifNAT@swa\ifcase\NAT@ctype
        \if\relax\NAT@date\relax
          \@citea\NAT@hyper@{\NAT@nmfmt{\NAT@nm}\NAT@date}%
        \else
          \ifx\NAT@last@nm\NAT@nm\NAT@yrsep
              \ifx\NAT@last@yr\NAT@year
                \def\NAT@temp{{?}}%
                \ifx\NAT@temp\NAT@exlab\PackageWarningNoLine{natbib}%
                {Multiple citation on page \thepage: same authors and
                year\MessageBreak without distinguishing extra
                letter,\MessageBreak appears as question mark}\fi
                \NAT@hyper@{\NAT@exlab}%
              \else\unskip\NAT@spacechar
                \NAT@hyper@{\NAT@date}%
              \fi
          \else
            \@citea\NAT@hyper@{%
              \NAT@nmfmt{\NAT@nm}%
              \hyper@natlinkbreak{%
                \NAT@aysep\NAT@spacechar}{\@citeb\@extra@b@citeb
              }%
              \NAT@date
            }%
          \fi
        \fi
      \or\@citea\NAT@hyper@{\NAT@nmfmt{\NAT@nm}}%
      \or\@citea\NAT@hyper@{\NAT@date}%
      \or\@citea\NAT@hyper@{\NAT@alias}%
      \fi \NAT@def@citea
      \else
        \ifcase\NAT@ctype
          \if\relax\NAT@date\relax
            \@citea\NAT@hyper@{\NAT@nmfmt{\NAT@nm}}%
          \else
          \ifx\NAT@last@nm\NAT@nm\NAT@yrsep
              \ifx\NAT@last@yr\NAT@year
                \def\NAT@temp{{?}}%
                \ifx\NAT@temp\NAT@exlab\PackageWarningNoLine{natbib}%
                {Multiple citation on page \thepage: same authors and
                year\MessageBreak without distinguishing extra
                letter,\MessageBreak appears as question mark}\fi
                \NAT@hyper@{\NAT@exlab}%
              \else
                \unskip\NAT@spacechar
                \NAT@hyper@{\NAT@date}%
              \fi
          \else
            \@citea\NAT@hyper@{%
              \NAT@nmfmt{\NAT@nm}%
              \hyper@natlinkbreak{\NAT@spacechar\NAT@@open\if*#1*\else#1\NAT@spacechar\fi}%
                {\@citeb\@extra@b@citeb}%
              \NAT@date
            }%
          \fi
          \fi
        \or\@citea\NAT@hyper@{\NAT@nmfmt{\NAT@nm}}%
        \or\@citea\NAT@hyper@{\NAT@date}%
        \or\@citea\NAT@hyper@{\NAT@alias}%
        \fi
        \if\relax\NAT@date\relax
          \NAT@def@citea
        \else
          \NAT@def@citea@close
        \fi
      \fi
      }}\ifNAT@swa\else
        % 将 author-year 式 \cs{citet} 引用的页码置于括号外并改为上标。
        %
        % \if*#2*\else\NAT@cmt#2\fi
        \if\relax\NAT@date\relax\else\NAT@@close\fi
        \if*#2*\else\textsuperscript{#2}\fi
      \fi}{#1}{#2}}
  %
  % 为了将参考文献加入目录和 pdf 书签，重新定义 \pkg{natbib} 的 \cmd{bibsection}
  % 另外如果调用了 \pkg{chapterbib} 或者使用了 \opt{sectionbib} 参数，
  % 需要使用节标题 \cs{section}。
\newcommand\xynu@bib@chapter{%
  \begingroup % 1. 开启局部环境
    % 2. 在这里单独定义参考文献的标题格式
    \ctexset{
       chapter/beforeskip = 24bp,    % 段前距离
       chapter/afterskip  = 24bp,    % 段后距离
       chapter/numbering  = false,  % <--- 【关键修改】强制关闭编号！
       % chapter/format = \centering\heiti\zihao{3}, % 如需修改字体可取消注释
    }%
    % 3. 生成标题 (此时它就不会带“第5章”了)
    \chapter{\bibname}%
  \endgroup   % 4. 关闭局部环境
}%

  \newcommand\xynu@bib@section{%
    \begingroup
      \ctexset{section/numbering=false}%
      \section{\bibname}%
    \endgroup
  }%
  \@ifpackagewith{chapterbib}{sectionbib}{%
    \xynu@error{The "sectionbib" option cannot be used with chaperbib if natbib loaded}%
  }{}%
  \@ifpackageloaded{chapterbib}{%
    \let\bibsection\xynu@bib@section
  }{%
    \@ifxundefined\NAT@sectionbib{%
      \let\bibsection\xynu@bib@chapter
    }{%
      \let\bibsection\xynu@bib@section
    }%
  }%
}


% biblatex 宏包的配置

\AtEndOfPackageFile*{biblatex}{
  \DeclareRobustCommand\inlinecite{\parencite}
  \defbibheading{bibliography}[\bibname]{%
    \@mainmatterfalse
    \chapter{\bibname}%
  }
  \renewcommand\bibfont{%
    \fontsize{10.5bp}{20bp}\selectfont
  }
  \setlength{\bibitemsep}{0\p@ \@plus.2\p@}
  \setlength{\bibhang}{21bp}
}

% \subsection{附录}

% 定义了一个满足要求的致谢环境：
\newenvironment{acknowledgements}{%
  \@mainmatterfalse
  \chapter{\xynu@acknowledgements@name}%
}{
}


% 兼容旧版本中“acknowledgments”的拼法。
% Deprecated since 2020-07-01.
\newenvironment{acknowledgments}{%
  \begin{acknowledgements}%
}{%
  \end{acknowledgements}%
}

% 科研成果环境：
\NewDocumentEnvironment{achievements}{+b}{%
  \@mainmatterfalse
  \chapter{\xynu@achievements@name}%
  \fontsize{12bp}{16bp}\selectfont
  #1\par
}{}

% 兼容旧的接口
\newenvironment{publications}{%
  \xynu@deprecated{'publications' environment}{2024-12-15}{'achievements'}%
  \@mainmatterfalse
  \chapter{\xynu@achievements@name}%
}{}

\newif\ifxynu@first@achievement@list
\xynu@first@achievement@listtrue

\newenvironment{theachievements}[1][已发表论文]{%
  \ifxynu@first@achievement@list
    \vspace{1bp}%
  \else
    \vspace{19bp}%
  \fi
  \global\xynu@first@achievement@listfalse
  \noindent\textbf{#1：}\par
  \begin{achievementlist}
}{%
  \end{achievementlist}
}

\newlist{achievementlist}{enumerate}{1}
\setlist[achievementlist]{
  topsep     = 3bp,
  partopsep  = 0bp,
  itemsep    = 0bp,
  parsep     = 3bp,
  leftmargin = 21bp,
  itemindent = 0bp,
  labelsep   = 0bp,
  labelwidth = 21bp,
  align      = left,
  label      = [\arabic*],
}



% \subsection{其他宏包的设置}

% 这些宏包并非格式要求，但是为了方便同学们使用，在这里进行简单设置。


% \subsubsection{\pkg{hyperref} 宏包}

\AtEndOfPackageFile*{hyperref}{
  \hypersetup{
    bookmarksnumbered  = true,
    bookmarksopen      = true,
    bookmarksopenlevel = 1,
    linktoc            = all,
    unicode            = true,
    psdextra           = true,
  }
  %
  % 如果为 \opt{pdf} 样式，设置 hyperlink 颜色
  \ifxynu@output@electronic
    \hypersetup{
      colorlinks = true,
      allcolors  = blue,
    }
  \else
    \hypersetup{hidelinks}
  \fi
  %
  % 填写 PDF 元信息。
  \AtBeginDocument{%
    \ifxynu@main@language@chinese
      \hypersetup{
        pdftitle  = \xynu@title,
        pdfauthor = \xynu@author,
      }%
    \else
      \hypersetup{
        pdftitle  = \xynu@title@en,
        pdfauthor = \xynu@author@en,
      }%
    \fi
  }
  %
  % 添加 PDF 书签
  %
  \newcounter{xynu@bookmarknumber}
  \renewcommand\xynu@pdfbookmark[1]{%
    \phantomsection
    \stepcounter{xynu@bookmarknumber}%
    \pdfbookmark[0]{#1}{xynuchapter.\thexynu@bookmarknumber}%
  }
  %
  % 在 PDF 字符串中去掉换行，以减少 \pkg{hyperref} 的警告信息。
  \pdfstringdefDisableCommands{
    \let\\\@empty
    \let\hspace\@gobble
  }
  %
  % \pkg{hyperref} 与 \pkg{unicode-math} 存在一些兼容性问题，见
  % \href{https://github.com/xynutug/xynuthesis/issues/223}{%
  %   xynutug/xynuthesis\#223}，
  % \href{https://github.com/ho-tex/hyperref/pull/90}{ho-tex/hyperref\#90} 和
  % \href{https://github.com/xynutug/xynuthesis/issues/235}{%
  %   xynutug/xynuthesis/\#235}。
  \@ifpackagelater{hyperref}{2019/04/27}{}{%
    \g@addto@macro\psdmapshortnames{\let\mu\textmu}%
  }
  %
  % 设置中文的 \cs{autoref}。
  % \footnote{\url{https://tex.stackexchange.com/a/66150/82731}}
  \ifxynu@language@chinese
    \def\equationautorefname~#1\null{公式~(#1)\null}
    \def\footnoteautorefname{脚注}
    \def\itemautorefname~#1\null{第~#1~项\null}
    \def\figureautorefname{图}
    \def\tableautorefname{表}
    \def\partautorefname~#1\null{第~#1~部分\null}
    \def\appendixautorefname{附录}
    \def\chapterautorefname~#1\null{第~#1~章\null}
    \def\sectionautorefname~#1\null{第~#1~节\null}
    \def\subsectionautorefname~#1\null{第~#1~小节\null}
    \def\subsubsectionautorefname~#1\null{第~#1~小小节\null}
    \def\paragraphautorefname~#1\null{第~#1~段\null}
    \def\subparagraphautorefname~#1\null{第~#1~小段\null}
    \def\theoremautorefname{定理}
    \def\HyRef@autopageref#1{\hyperref[{#1}]{第~\pageref*{#1} 页}}
  \fi
  %
  % 如果在 \tableofcontents 处切换 \pagenumbering，
  % 在使用了 notoccite 后会导致 PDF 书签的页码有误（#293），
  % 所以需要补充 https://tex.stackexchange.com/a/593839/82731 的 patch。
  % LuaTeX 不需要这个 patch。
  \ifXeTeX
    \def\HyPL@StorePageLabel#1{%
      \begingroup
        \edef\Hy@tempa{\the\Hy@abspage<<#1>>}%
        \immediate\write\@mainaux{%
          \string\HyPL@Entry{\Hy@tempa}%
        }%
      \endgroup
    }
  \fi
}


% \subsubsection{\pkg{amsthm} 宏包}

\AtEndOfPackageFile*{amsthm}{
  \newtheoremstyle{xynuplain}
    {}{}
    {}{2em}
    {\bfseries}{}
    {1em}{}
  \theoremstyle{xynuplain}
  % 定义新的定理
  \ifxynu@language@chinese
    \newcommand\xynu@assertion@name{断言}
    \newcommand\xynu@assumption@name{假设}
    \newcommand\xynu@axiom@name{公理}
    \newcommand\xynu@corollary@name{推论}
    \newcommand\xynu@definition@name{定义}
    \newcommand\xynu@example@name{例}
    \newcommand\xynu@lemma@name{引理}
    \newcommand\xynu@proof@name{证明}
    \newcommand\xynu@proposition@name{命题}
    \newcommand\xynu@remark@name{注}
    \newcommand\xynu@theorem@name{定理}
  \else
    \newcommand\xynu@assertion@name{Assertion}
    \newcommand\xynu@assumption@name{Assumption}
    \newcommand\xynu@axiom@name{Axiom}
    \newcommand\xynu@corollary@name{Corollary}
    \newcommand\xynu@definition@name{Definition}
    \newcommand\xynu@example@name{Example}
    \newcommand\xynu@lemma@name{Lemma}
    \newcommand\xynu@proof@name{Proof}
    \newcommand\xynu@proposition@name{Proposition}
    \newcommand\xynu@remark@name{Remark}
    \newcommand\xynu@theorem@name{Theorem}
  \fi
  \newtheorem{theorem}             {\xynu@theorem@name}    [chapter]
  \newtheorem{assertion}  [theorem]{\xynu@assertion@name}
  \newtheorem{axiom}      [theorem]{\xynu@axiom@name}
  \newtheorem{corollary}  [theorem]{\xynu@corollary@name}
  \newtheorem{lemma}      [theorem]{\xynu@lemma@name}
  \newtheorem{proposition}[theorem]{\xynu@proposition@name}
  \newtheorem{assumption}          {\xynu@assumption@name} [chapter]
  \newtheorem{definition}          {\xynu@definition@name} [chapter]
  \newtheorem{example}             {\xynu@example@name}    [chapter]
  \newtheorem*{remark}             {\xynu@remark@name}
  % \pkg{amsthm} 单独定义了 proof 环境，这里重新定义以满足格式要求。
  % 原本模仿 \pkg{amsthm} 写成 |\item[\hskip\labelsep\hskip2em #1\hskip1em]|，
  % 但是却会多出一些间隙。
  \renewenvironment{proof}[1][\xynu@proof@name]{\par
    \pushQED{\qed}%
    \normalfont \topsep6\p@\@plus6\p@\relax
    \trivlist
      \item\relax\hskip2em\relax
      \textbf{#1}
      \hskip1em\ignorespaces
    }{%
    \popQED\endtrivlist\@endpefalse
  }
  \renewcommand\qedsymbol{\xynu@qed}
}


% \subsubsection{\pkg{algorithm2e} 宏包}

% 按章节编号。
\PassOptionsToPackage{algochapter}{algorithm2e}

\AtEndOfPackageFile*{algorithm2e}{
  \ifxynu@language@chinese
    \SetAlgorithmName{算法}{算法}{算法清单}
  \else
    \SetAlgorithmName{Algorithm}{Algorithm}{List of Algorithms}
  \fi
  %
  % 设置算法环境的格式。
  \SetAlCapSkip{6bp}
  \SetAlCapFnt{\small}
  \SetAlCapNameFnt{\small}
  \SetAlCapNameSty{textbf}
  \SetAlgoCaptionSeparator{\unskip\hspace*{1em}}
  %
  % 设置算法清单的格式
  \renewcommand\listofalgocfs{%
    \cleardoublepage
    \xynu@chapter{\listalgorithmcfname}%
    \@starttoc{loa}%
  }
  \titlecontents{algocf}
    [2.3em]{\normalsize}
    {\contentslabel{2.3em}}{}
    {\xynu@leaders\contentspage}
  \contentsuse{algocf}{loa}
}


% \subsubsection{\pkg{mathtools} 宏包}

% \pkg{mathtools} 会修改 \pkg{unicode-math} 的 `\underbrace` 和 `\overbrace`，
% 需要还原为 `\LaTeXunderbrace` 和 `\LaTeXoverbrace`，
% 参考 \url{https://tex.stackexchange.com/q/521394/82731}。
\AtEndOfPackageFile*{mathtools}{
  \@ifpackageloaded{unicode-math}{
    \let\underbrace\LaTeXunderbrace
    \let\overbrace\LaTeXoverbrace
  }{}
}

% \subsubsection{\pkg{nomencl} 宏包}

\PassOptionsToPackage{notocbasic}{nomencl}

\AtEndOfPackageFile*{nomencl}{
  \let\nomname\xynu@notation@name
  \def\thenomenclature{%
    \xynu@chapter{\xynu@notation@name}%
    \nompreamble
    \list{}{%
      \labelwidth\nom@tempdim
      \leftmargin\labelwidth
      \advance\leftmargin\labelsep
      \itemsep\nomitemsep
      \let\makelabel\nomlabel}}
  \def\endthenomenclature{%
    \endlist
    \nompostamble
  }
}


% \subsubsection{\pkg{siunitx} 宏包}

\AtEndOfPackageFile*{siunitx}{
  \newcommand\xynu@set@siunitx@language{%
    \ifxynu@language@chinese
      \sisetup{
        list-final-separator = { 和~},
        list-pair-separator  = { 和 },
        range-phrase         = {～},
      }%
    \else
      \sisetup{
        list-final-separator = {, and },
        list-pair-separator  = { and },
        range-phrase         = { to },
      }%
    \fi
  }
  \xynu@set@siunitx@language
  \xynu@option@hook{language}{\xynu@set@siunitx@language}
}

% \subsubsection{\pkg{chapterbib} 宏包}

\AtEndOfPackageFile*{chapterbib}{
  \@ifpackageloaded{natbib}{%
    \@ifpackagewith{chapterbib}{sectionbib}{%
      \xynu@error{The "sectionbib" option cannot be used with chaperbib if natbib loaded}%
    }{}%
    \renewcommand\bibsection{%
      \begingroup
        \ctexset{section/numbering=false}%
        \section{\bibname}%
      \endgroup
    }
  }{}
}
