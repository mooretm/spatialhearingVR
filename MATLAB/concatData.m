function concatData(exp,conds,verbose)

% numConds: the number of conditions for dataCrawler to crawl
% verbose: 1 = show goDataCrawler output; 0 = suppress output

if strcmp(exp,'MOCS')
    for ii = 1:(length(conds))
        doDataCrawler(conds(ii),verbose);
    end
elseif strcmp(exp,'MOA')
    for jj = 1:(length(conds))
    doDataCrawlMOA(conds(jj),verbose);
    end
end
