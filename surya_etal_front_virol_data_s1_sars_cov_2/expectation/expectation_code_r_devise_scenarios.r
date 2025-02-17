# Written by Kevin Surya.
# This code is part of the coronavirus-evolution project.


# library(ape)
library(Cairo)
library(geiger)
library(ggimage)
library(ggplot2)
library(ggthemes)
library(ggtree)
library(phytools)
library(svglite)


# Create a tree ----
set.seed(2)
tree <- ladderize(rtree(n = 10), right = FALSE)

# Plot the tree ----
plot_tree <-
  ggtree(tree, size = 0.5) +
    geom_rootedge(1) +
    theme_tree2() +
    labs(caption = "Time")

# Save the timetree plot ----
CairoSVG(file = "figure_tree.svg", width = 4.75, height = 2.94)
print(plot_tree)
graphics.off()

# Create a timetree ----
set.seed(9011)
tree_time <- rtree(n = 1000)
tree_time <- rescale(tree_time, model = "kappa", 3)

# Create a molecular tree (punctuated evolution) ----
tree_mol <- rescale(tree_time, model = "kappa", 0)
tree_mol$edge.length <-
  tree_mol$edge.length +
  abs(rnorm(n = length(tree_mol$edge.length), mean = 0, sd = 0.05))

# Extract data ----
path_time <- diag(vcv(phy = tree_time))
path_mol <- diag(vcv(phy = tree_mol))
node <- NULL
for (genome in 1:length(tree_time$tip.label)) {
  node[genome] <- length(
    nodepath(
      phy = tree_time,
      from = length(tree_time$tip.label) + 1,
      to = genome
    )
  ) - 2
  names(node)[genome] <- tree_time$tip.label[genome]
}
dat <- data.frame(path_time, path_mol, node)
dat$node_grad <- sample(dat$node, size = length(dat$node))

# Plot regressions ----
plot_reg_grad_strict <-
  ggplot(dat, aes(x = path_time, y = path_time, color = node_grad)) +
    geom_point(size = 2) +
    scale_colour_gradient(
      low = "gray75",
      high = "gray0",
      breaks = c(max(dat$node), min(dat$node)),
      labels = c("high", "low")
    ) +
    guides(colour = guide_colourbar(barwidth = 0.25, ticks = FALSE)) +
    theme_tufte(base_size = 14, base_family = "Arial", ticks = FALSE) +
    theme(axis.text.x = element_blank(), axis.text.y = element_blank()) +
    labs(
      x = "\nSampling time",
      y = "Root-to-tip divergence\n",
      color = "Node\ncount\n"
    )
plot_reg_grad_relaxed <-
  ggplot(dat, aes(x = path_time, y = path_mol, color = node_grad)) +
    geom_point(size = 2) +
    scale_colour_gradient(
      low = "gray75",
      high = "gray0",
      breaks = c(max(dat$node), min(dat$node)),
      labels = c("high", "low")
    ) +
    guides(colour = guide_colourbar(barwidth = 0.25, ticks = FALSE)) +
    theme_tufte(base_size = 14, base_family = "Arial", ticks = FALSE) +
    theme(axis.text.x = element_blank(), axis.text.y = element_blank()) +
    labs(
      x = "\nSampling time",
      y = "Root-to-tip divergence\n",
      color = "Node\ncount\n"
    )
plot_reg_punc <-
  ggplot(dat, aes(x = path_time, y = path_mol, color = node)) +
    geom_point(size = 2) +
    scale_colour_gradient(
      low = "gray75",
      high = "gray0",
      breaks = c(max(dat$node), min(dat$node)),
      labels = c("high", "low")
    ) +
    guides(colour = guide_colourbar(barwidth = 0.25, ticks = FALSE)) +
    theme_tufte(base_size = 14, base_family = "Arial", ticks = FALSE) +
    theme(axis.text.x = element_blank(), axis.text.y = element_blank()) +
    labs(
      x = "\nSampling time",
      y = "Root-to-tip divergence\n",
      color = "Node\ncount\n"
    )

# Save scatter plots ----
CairoSVG(
  file = "figure_regression_grad_strict.svg",
  width = 4.75,
  height = 2.94
)
print(plot_reg_grad_strict)
graphics.off()
CairoSVG(
  file = "figure_regression_grad_relaxed.svg",
  width = 4.75,
  height = 2.94
)
print(plot_reg_grad_relaxed)
graphics.off()
CairoSVG(file = "figure_regression_punc.svg", width = 4.75, height = 2.94)
print(plot_reg_punc)
graphics.off()
