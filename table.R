# First calculate pf, then a life table
pf <- function(m, c=1, r=1){
	mx <- length(m)
	c <- rep(c, length.out=mx)
	r <- rep(r, length.out=mx)
	f <- r*m*c[[1]]
	p <- c(r[-mx]*c[-1], 0)
	return(lt(f, p))
}

# Calculate a life table given p and f
lt <- function(f, p){
	mx <- length(f)
	l <- cumprod(c(1, p[-mx]))
	contr <- l*f
	return(data.frame(f=f, p=p, l=l, contr=contr))
}
