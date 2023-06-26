# How ligands and flex orgnized in cuvina
for each model, vina has 2 lists, each for ligands and flex. Both ligand and flex are h-trees, which
means the root has a different type from branches.
For ligand, the root type is rigid_body and for flex it is first_segment.
Other nodes in ligands and flex are segment.

But for better concurrency design in cuda, we treat all nodes be the same, because they are not
so different in the perspective view of data design, except the rigid_body has a virtual `axis`
member in it.

The difference of root and branches are shown in the calculation, but they are all `Segment`.

Further more, we assembled `Segment` in all nodes in ligands and flex togather into a list(`SrcModel::segs), and some indices are used to tell the start of the tree, the end of the tree,
and the structure inside the tree. The data structure to describe a tree is `Ligand`.


# how change and conf saved inside Flt flow
Since we merged all nodes into a list, it is natually that we merge the change and conf of each
ligands and flex into a Flt list. 

# What is model desc, and how the data orgnized
