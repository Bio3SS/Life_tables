tab <- pf(m, r=g)

mtab <- t(as.matrix(with(tab, data.frame(
	p=p, f=f
))))

ssvname <- paste0(rtargetname, ".ssv")
write.table(mtab, ssvname, row.names=FALSE, col.names=FALSE)
