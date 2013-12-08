% Informierte Suche

eval_paths([],_).

eval_paths([FirstPath|RestPaths],Heuristik):-
  eval_path(FirstPath,Heuristik),
  eval_paths(RestPaths,Heuristik).

insert_new_paths_informed([],OldPaths,OldPaths).

insert_new_paths_informed([FirstNewPath|RestNewPaths],OldPaths,AllPaths):-
  insert_path_informed(FirstNewPath,OldPaths,FirstInserted),
  insert_new_paths_informed(RestNewPaths,FirstInserted,AllPaths).

insert_path_informed(NewPath,[],[NewPath]).

% Wenn der Pfad billiger ist, dann wird er vorn angefügt. (Alte Pfade sind ja sortiert.)
%
insert_path_informed(NewPath,[FirstPath|RestPaths],[NewPath,FirstPath|RestPaths]):-
  cheaper(NewPath,FirstPath),!.

% Wenn er nicht billiger ist, wird er in den Rest einsortiert und der Kopf 
% der Openliste bleibt Kopf der neuen Liste
%
insert_path_informed(NewPath,[FirstPath|RestPaths],[FirstPath|NewRestPaths]):-
  insert_path_informed(NewPath,RestPaths,NewRestPaths).  

min_list([Return], Return).

min_list([FirstNode|RestNodes], MinRest):-
  min_list(RestNodes, MinRest),
  min(FirstNode, MinRest, MinRest).

min(Node1, Node2, Return):-
  ((_,_,Value1) = Node1,
  (_,_,Value2) = Node2,
  Value1 < Value2,
  Return = Node1),!;
  Return = Node2.
  
cheaper([(_,_,V1)|_],[(_,_,V2)|_]):-
  V1 =< V2.