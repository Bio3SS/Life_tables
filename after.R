tab <- pf(m, r=g)

mtab <- t(as.matrix(with(tab, data.frame(
	p=p, f=f
))))

write.table(mtab, "RTARGET.ssv", row.names=FALSE, col.names=FALSE)
