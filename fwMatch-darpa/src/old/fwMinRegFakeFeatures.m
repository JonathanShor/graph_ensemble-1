function [W, objectives, beliefs] = fwMinRegFakeFeatures(X, lambda, varargin)
% learnBetheFakeFeatures

[M, D] = size(X);

K = D * D;
features = cell(M, K);

for m = 1:M
    for k = 1:K
        [i, j] = ind2sub([D D], k);
        features{m,k} = zeros(D);
        features{m,k}(i,j) = 1;
    end
end

[theta beliefs objectives] = fwMinRegFeats_mex(X, features, lambda, varargin{:});
% [theta beliefs objectives] = fwMinRegFeats(X, features, lambda, varargin{:});

W = reshape(theta, D, D);

end
