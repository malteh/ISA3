:- consult('Suche_Modul_Allgemein.pl').
:- consult('Suche_Modul_Informierte_Suche.pl').

%%% Spezieller Teil: Wassergef‰ﬂe
% :- consult('Suche_Modul_Wasser.pl').

%%% Spezieller Teil: Planung
:- consult('Suche_Modul_Planung.pl').

%%% Aufrufe:
%:- solve(depth, _).
%:- solve(breadth, _).
%:- solve(informed, good).
%:- solve(informed, better).
%:- solve(a,_).
%:- solve(greedy,_).
%:- solve(hc_optimistic,_).
%:- solve(hc_backtracking,_).