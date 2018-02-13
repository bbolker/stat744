library(dplyr)
library(tidyr)

data(anscombe)

wide <- anscombe

anst <- (wide
	%>% mutate(obs=1:nrow(wide))
	%>% gather(lab, val, -obs)
	%>% separate(lab, c("vname", "set"), 1)
	%>% spread(vname, val)
)
