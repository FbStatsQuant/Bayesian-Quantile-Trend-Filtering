# Interface questions and candidate paper corrections

## Concentration variance proof (upstream of Localization)

The frozen concentration conclusion is sufficient for Localization. The paper's proof of Lemma `pf:lem:conc` bounds the change on replacing observation `i` by the magnitude of coordinate `i` of a maximizer. When the maximizer is taken at the original data, this controls the positive part of the change `G(y) - G(y^(i))`. An absolute-value bound would generally need a maximizer from whichever of the two data vectors gives the larger value, which can differ with `i` and would not justify summing the squared coordinates of one maximizer.

Suggested correction: fix a maximizer at the original data and use the one-sided Efron–Stein inequality. Swapping the original and replacement coordinate shows that the expectation of the squared difference is twice the expectation of its squared positive part. The same original-data maximizer bounds the positive parts for every coordinate, so their squared sum is bounded pointwise by `sup_{δ ∈ K} ‖δ‖₂²`. This leaves the statement unchanged.
