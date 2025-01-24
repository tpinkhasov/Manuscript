function y = sem(x,varargin)
% function returns standard error of the mean
% works for vectors and 2D-matrices
% works for vectors containing NaNs
%
% on Sep 12, 2012 I added some functionality from the function ste, available on Matlab Central File Exchange
% varargin now should be an integer specifying the dimension over which the SD should be computed
%
% Maik Oct 2011
% updated Feb 2013 -> now automatically computes std over correct dimension for vectors

if numel(size(x))>2
  disp('sorry, code only applicable for vectors and 2D matrices')
  return
end

if isvector(x)
  y = nanstd(x)/sqrt(sum(~isnan(x)));
else
  if nargin<2
    y = nanstd(x,0,1)./sqrt(sum(~isnan(x)));
  else
    y = nanstd(x,0,varargin{1})./sqrt(sum(~isnan(x),varargin{1}));
  end
end  
