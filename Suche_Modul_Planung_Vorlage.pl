% Die Schnittstelle umfasst
%   start_description	;Beschreibung des Startzustands
%   start_node          ;Test, ob es sich um einen Startknoten handelt
%   goal_node           ;Test, ob es sich um einen Zielknoten handelt
%   state_member        ;Test, ob eine Zustandsbeschreibung in einer Liste 
%                        von Zustandsbeschreibungen enthalten ist
%   expand              ;Berechnung der Kind-Zustandsbeschreibungen
%   eval-path		;Bewertung eines Pfades

start_description([
  block(block1),
  block(block2),
  block(block3),
  block(block4),  %mit Block4
  on(table,block2),
  on(table,block3),
  on(block2,block1),
  on(table,block4), %mit Block4
  clear(block1),
  clear(block3),
  clear(block4), %mit Block4
  handempty
  ]).

goal_description([
  block(block1),
  block(block2),
  block(block3),
  block(block4), %mit Block4
  on(block4,block2), %mit Block4
  on(table,block3),
  on(table,block1),
  on(block1,block4), %mit Block4
%  on(block1,block2), %ohne Block4
  clear(block3),
  clear(block2),
  handempty
  ]).

start_node((start,_,_)).

goal_node((_,State,_)):-
  goal_description(Goal), % Zielbedingungen einlesen
  mysubset(Goal, State). % Zustand gegen Zielbedingungen testen.

% Aufgrund der Komplexit�t der Zustandsbeschreibungen kann state_member nicht auf 
% das Standardpr�dikat member zur�ckgef�hrt werden.
state_member(_,[]):- !,fail.

state_member(State,[FirstState|_]):-
  % Test, ob State bereits durch FirstState beschrieben war. Tipp: Eine L�sungsm�glichkeit besteht in der Verwendung einer Mengenoperation, z.B. subtract
  subtract(State, FirstState, []), subtract(FirstState, State, []),!.  

% Es ist sichergestellt, dass die beiden ersten Klauseln nicht zutreffen.
state_member(State,[_|RestStates]):-  
  state_member(State, RestStates). % rekursiver Aufruf.

eval_path([(_,State,Value)|RestPath],a):-
  length(RestPath,L_RestPath),
  eval_state((_, State, Value_S),better),
  % ,"Rest des Literals bzw. der Klausel"
  % "Value berechnen".
  Value is L_RestPath + Value_S.

eval_path([(_,State,Value)|RestPath],Heuristik):-
  length(RestPath,L_RestPath),
  eval_state((_, State, Value_S),Heuristik),
  % ,"Rest des Literals bzw. der Klausel"
  % "Value berechnen".
  Value is L_RestPath + Value_S.
  
eval_path([Node|_], Heuristik):-
  eval_state(Node, Heuristik).

% Sehr einfache Heuristik
eval_state((_,_State,Value), simple):-
  Value is 0.

% Gute Heuristik
eval_state((_,State,Value), good):-
  goal_description(Goal),
  length(Goal,L_Goal),
  intersection(State,Goal,InGoalAndState),
  length(InGoalAndState,L_InGoalAndState),
  Value is L_Goal - L_InGoalAndState.

% Bessere Heuristik
eval_state((_,State,Value), better):-
  goal_description(Goal),
  length(Goal,L_Goal),
  intersection(State,Goal,InGoalAndState),
  length(InGoalAndState,L_InGoalAndState),
  % on(X,Y) is aufwaendiger, als z.B. clear(X) und z�ht deshalb doppelt
  subtract(Goal,State,RestGoal),
  on_counter(RestGoal,OnCount),
  Value is L_Goal - L_InGoalAndState + OnCount.

on_counter([],0).
on_counter([on(_,_)|T],Count):-
  on_counter(T,Count_rec),
  Count is Count_rec + 1,!.
on_counter([_|T],Count):-
  on_counter(T,Count_rec),
  Count is Count_rec.

action(pick_up(X),
       [handempty, clear(X), on(table,X)],
       [handempty, clear(X), on(table,X)],
       [holding(X)]).

action(pick_up(X),
       [handempty, clear(X), on(Y,X), block(Y)],
       [handempty, clear(X), on(Y,X)],
       [holding(X), clear(Y)]).

action(put_on_table(X),
       [holding(X)],
       [holding(X)],
       [handempty, clear(X), on(table,X)]).

action(put_on(Y,X),
       [holding(X), clear(Y)],
       [holding(X), clear(Y)],
       [handempty, clear(X), on(Y,X)]).

% Hilfskonstrukt, weil das PROLOG "subset" nicht die Unifikation von Listenelementen 
% durchf�hrt, wenn Variablen enthalten sind. "member" unifiziert hingegen.
%
mysubset([],_).
mysubset([H|T],List):-
  member(H,List),
  mysubset(T,List).

expand_help(State,Name,NewState):-
  % "Action suchen"
  action(Name, Conditions, Del, Add),
  % "Conditions testen"
  mysubset(Conditions, State),
  % "Del-List umsetzen"
  subtract(State, Del, Diff),
  % "Add-List umsetzen"
  append(Diff, Add, NewState).
  
expand((_,State,_),Result):-
  findall((Name,NewState,_),expand_help(State,Name,NewState),Result).