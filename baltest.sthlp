{smcl}
{* *! version 1.2  june2013}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Options" "examplehelpfile##options"}{...}
{viewerjumpto "Remarks" "examplehelpfile##remarks"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{title:Title}

{phang}
{bf:baltest} {hline 2} Perform balancing tests on the matched sample

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:baltest}
{varlist}
{ifin}
{cmd:,} {it:psmvar({varname}) obsvar({varname}) [options]}

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opth psm:var(varname)}}[required] match variable that resulted from the gen option of {help teffects psmatch}{p_end}
{synopt:{opth obs:var(varname)}}[required] before running {help teffect psmatch}, it is required to have generated an observation number variable{p_end}
{synopt:{opt sig:level(number)}}select the significance level at which the significance star is triggered; 
        default is {cmd:siglevel(.05)}{p_end}
{synopt:{opth savem:atch(`tempfile')}}save the matched sample to a previously defined tempname; 
        note that the single quotes are required{p_end}
{synopt:{cmd:cntrep({varname})}}report how many times controls were matched to treatments{p_end}
{synopt:{opt n:}}display control and treatment sample sizes{p_end}
        
{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:baltest} conducts a balancing test on the matched sample (as previously matched by {help teffects psmatch}) using the specified variables in the
{varlist}.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt psmvar} variable indicating what observation number of its match; this variable is specified by the gen option of {help teffects psmatch}; an index number must be chosen (most likelly 1).

{phang}
{opt obsvar} in order for {cmd:baltest} to work, prior to running {help teffects psmatch} the user must create an observation 
number variable corresponding to the sorting order prior to running {help teffects psmatch}. For example gen ob=_n. 

{phang}
{opt siglevel} postestimation command {cmd:baltest} will run {help ttest}s on the {varlist} variables and display a star if the pvalue is below the assigned level. If no number is specified 0.05 is assumed.  

{phang}
{opt sigsort} will display the unmatched covariates (pvalue<{cmd:siglevel})-if any-on top of the balance table. 

{phang}
{opth savematched(`tempfile')} gives the option to save the matched sample to a previously specified {help tempfile}, thus the need to include single quotes when entering this option. 

{phang}
{opth cntrep(varname)} if matching with replacement was allowed, this option enables the user to see how many times controls were matched treatments. 

{phang}
{opt n} displays columns for the matched control and matched treatment sample sizes. 

{marker remarks}{...}
{title:Remarks}

{pstd}
Note that this command is suitable for binary treatment variables only. {p_end}
distinct should be installed prior to running this command. {p_end}

{marker example}{...}
{title:Example}

{phang} {cmd:. tempfile} matched_sample{p_end}
{phang} {cmd:. gen} ob=_n{p_end} 
{phang} {cmd:. teffects psmatch} (outcomevar) (treatmentvar covariate1 covariate2 covariate3... covariateK), gen(match){p_end} 
{phang} {cmd:. baltest} covariate1 covariate2 covariate3... covariateK, psm(match1) obs(ob) cntrep(ob_id) savem(`matched_sample'){p_end}


