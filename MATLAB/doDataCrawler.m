function [Y] = doDataCrawler(condNum,verbose)

% Crawl data for MOCS experiments for 1 specified condition.
%   Called by wrapper function 'concatData.m' to handle arrays of 
%   conditions. I.E., this function does not loop for multiple conditions.

folderList = dir('Travis_Dissertation');
numFolders = length(folderList);

Y = []; % dimension an empty matrix to hold values

if verbose == 1
    fprintf('\n\nPulling data...\n')
end

for files = 3:numFolders % start at 3 to avoid the '.' and '..'
    fileName = folderList(files).name;
    
    if verbose == 1
        fprintf('\nSubject: %s\n', fileName)
    end
    
    myPath = ['Travis_Dissertation/', fileName, '/'];
    load([myPath, fileName '.mat']);

    x = size(data.condition(condNum).trials(:,:,:));
    if x(1) > 0 && numel(x) == 2 % single row/block
        z = data.condition(condNum).trials(:,:,:);
        %z = [repmat(name2,x(1),1),z]; % append subject number to data
        Y = [Y;z];
        if verbose == 1
            fprintf('Condition: %s\n',data.key{condNum});
            fprintf('Blocks found: 1\n');
        end
    elseif x(1) > 0 && numel(x) == 3 % multiple rows/blocks
        for blocks = 1:x(3);
        z = data.condition(condNum).trials(:,:,blocks);
        %z = [repmat(name2,x(1),1),z]; % append subject number to data
        Y = [Y;z];
        end
        if verbose == 1
            fprintf('Condition: %s\n',data.key{condNum});
            fprintf('Blocks found: %d\n',x(3));
        end
    end
end

% save data to txt file
if ~isempty(Y)
    Y = sortrows(Y,[1,3,5,7]);

    % remove zeros (which have been sorted to the top of the matrix)
    while Y(1,:) == 0
        Y(1,:) = [];
    end
    
    if verbose == 1
        fprintf('\nWriting to disk...\n')
    end
    
    % write output to file
    myFile = sprintf('Condition_%d.txt', condNum);
    dlmwrite(myFile,Y,'delimiter','\t');
end

if verbose == 1
    fprintf('\nFinished successfully\nGoodbye!\n\n');
end




