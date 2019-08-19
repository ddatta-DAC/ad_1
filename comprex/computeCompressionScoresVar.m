function [scores] = computeCompressionScoresVar( datafile, CTfile )

load(CTfile);
size(CT)
[CT] = modify_CT(CT)
data = textread(datafile);
[N f] = size(data)


scores = zeros(N,1);

for i=1:N
    d = data(i,:);
    
    for j=1:size(CT,1)
        dims = CT{j,1};
        dd = d(dims);
        
        els = CT{j,3};
        codeLens = CT{j,4};		
		
		for k=length(els):-1:1			
			[dd covers] = isincover (dd, els{k});
			% covers: true/false
			% dd: remaining uncovered part
			if(covers)
				scores(i) = scores(i) + codeLens(k);
%    				assert(scores(i)<inf)
                if scores(i)>=inf
                    scores(i) = realmax('single');
                end
			end
			if(length(dd) == 0)
				break;
			end
        end
    end
end

% --------------------
% No sorting needed 
% Just return in order of the obtained scores
% --------------------

save(strcat(CTfile,'_scores.mat'),'scores');
dlmwrite(strcat(CTfile,'_scores.txt'), scores);
return

 
[sscores ind] = sort(scores,'descend');

%dlmwrite(strcat(CTfile,'_sscores.txt'), [sscores ind]);
%return;

%mod = load(matdatafile)
%label = mod.label;
%data = mod.data;

% Adding 1 to all labels
label = textread(labelfile)+1;

disp(label)

val = unique(label);
c = histc(label,1:1:max(val));
tk = length(label);
sizes = c(label(ind(1:tk)));
ix = find(sizes == min(sizes));
ix;

topk = [ind(1:tk) sizes sscores(1:tk) data(ind(1:tk),:)];
%save(strcat(CTfile,'_topk.mat'),'topk');
dlmwrite(strcat(CTfile,'_topk.txt'), topk, 'delimiter','\t')


% load 'data/email'
% email = email(ind(1:k));
% save('topk_email.mat','email')
function [dd covers] = isincover (dd, elj)
	%ind = ismember(dd, elj(1)); 
	%for t=2:length(elj)
	%	ind = ind + ismember(dd, elj(t)); 
	%end
	[trash, ai, trash] = intersect(dd, elj);
	
	%if(sum(ind) == length(elj)) %includes/covers this element
	if(length(ai) == length(elj)) %includes/covers this element
		%ix = find(ind>0);
		%dd(ix) = [];
		covers = true;
		dd(ai) = [];
	else
		covers = false;
	end
end
end

