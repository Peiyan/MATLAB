%kigamut 'Compress Color Multiband Image to Single Band with Map'
% This MatLab function was automatically generated by a converter (KhorosToMatLab) from the Khoros igamut.pane file
%
% Parameters: 
% InputFile: i 'Input Image', required: 'Multiband input image (elements dimension > 1)'
% Integer: n 'Number of colors ', default: 240: 'Number of colors to compress down to'
% Integer: p 'Precision (bits) ', default: 8: 'Number of bits of precision to use in each band during quantization'
% Double: r 'Allocation fraction ', default: 0.5: 'Fraction of color splits based on subspace 2-norm'
% OutputFile: o 'Output File', required: 'output file'
%
% Example: o = kigamut(i, {'i','';'n',240;'p',8;'r',0.5;'o',''})
%
% Khoros helpfile follows below:
%
%  PROGRAM
% igamut - Compress Color Multiband Image to Single Band with Map
%
%  DESCRIPTION
% .I igamut
% takes a up to a 4 band multi-spectral image, where each band would 
% normally represent one component of a 24-bit color image (RGB, for 
% example), and generates a pseudo color image with a specified
% number of colors that can be displayed.  The object is to make the 
% quantized image look like the original 24-bit image even though the 
% number of colors is greatly restricted.
% 
% The quantization is performed by isolating clusters of
% "neighboring" color vectors in a three dimensional histogram, with
% each axis being one of the color components.  The clusters
% are obtained using a modified version of Heckbert's median
% cut.  The true colors are then matched to the closest cluster, 
% and the input RGB triplet is then re-mapped to an n-color pseudo color image.
% 
% To keep the histogram from becoming exceedingly large (max
% of around 2^24 bytes), one may need to  quantize the grey
% levels of the input bands to less than 8 bits. 6 bits (64
% levels) gives results that are reasonable in a short amount
% of time. The number of bits that are kept is called the
% color precision, which can be specified at execution time.
% The general tradeoff is  that smaller precision is faster
% and takes less memory, but it looks worse too. High precision
% takes longer and great gobs of memory, but looks decent,
% provided that a reasonable number (say 128 or more) colors is specified.
% The execution time is very dependent on the image
% statistics. In general, a small number of colors is faster
% than a large number of colors.  In either case, if the image
% has good spatial color coherence, execution time is greatly
% reduced.
% 
% The allocation fraction (-r) controls how large areas of
% nearly the same color are handled. An allocation fraction of
% 0.0 will cause the large areas to be broken into as many
% colors as possible with the largest areas of a particular
% color range being broken first. An allocation fraction of
% 1.0 will attempt to preserve the detail in the image
% by preserving the color range of all parts of the image at the
% expense of smooth coloring of the larger areas. An allocation 
% fraction of around 0.2 to 0.5 gives very good results on most images.
% 
% As a special note, be sure that the input image has a map
% that has one-to-one correspondence to the pixel values (i.e.
% the pixel value is the grey level). If this is not the case,
% use kmapdata(1) to convert to a linear map.
% 
% If the input image contains less than the number of colors
% requested then the output image will contain only the number
% of colors present in the input image. The color map will
% contain the number of entries requested (meaning all colors
% in the image) with any extra entries zero padded.
% 
% No dithering is done by 
% .I igamut.
% Dithering in color space can
% often cause the image to look very noisy due to the color
% sensitivity of the eye. The result images from 
% .I igamut
% may display some banding effects (Mach bands), but these are often more
% tolerable visually than the noise that would result from a
% color dithering process. (Should someone be suddenly inspired, there is
% enough information stored in the internal data structures to permit
% detection of Mach bands and automatic suppression of these artifacts;
% a few hundred more lines of C code should suffice to accomplish this.)
% Adding a small amount of noise to the image before using 
% .I igamut
% can reduce Mach band effects greatly.
% 
% If the KHOROS_NOTIFY environment variable is set to KSYSLIB, then an
% additional diagnostic message, the number of colors actually
% found in the image, will be printed. The color count is subject
% to the color precision specified by the (-p) option.
% 
% Multiple plane images are processed by quantizing each plane
% independently, generating a corresponding plane of colors in the
% map. Thus an input object with (w,h,d,t,e)=(512,480,10,10,4) will
% result in an output object with a value segment with dimensions
% (512,480,10,10,1) and a map segment with dimensions (4,10,10,10,1).
%
%  
%
%  EXAMPLES
% % igamut -i lizard.rgb.viff -o lizard.240.viff -n 240 -p 8
% quantizes the colors present in the 24-bit RGB input file down to 240
% colors, using all 8 bits of each band of the input image.
%
%  "SEE ALSO"
% kmapdata(1)
%
%  RESTRICTIONS 
%
%  REFERENCES 
% The reference on which this routine is based is: P. Heckbert,
% "Color Image Quantization for Frame Buffer Display", Computer Graphics, 
% Vol. 16, No. 3, July 1982, p297.
%
%  COPYRIGHT
% Copyright (C) 1993 - 1997, Khoral Research, Inc. ("KRI")  All rights reserved.
% 


function varargout = kigamut(varargin)
if nargin ==0
  Inputs={};arglist={'',''};
elseif nargin ==1
  Inputs=varargin{1};arglist={'',''};
elseif nargin ==2
  Inputs=varargin{1}; arglist=varargin{2};
else error('Usage: [out1,..] = kigamut(Inputs,arglist).');
end
if size(arglist,2)~=2
  error('arglist must be of form {''ParameterTag1'',value1;''ParameterTag2'',value2}')
 end
narglist={'i', '__input';'n', 240;'p', 8;'r', 0.5;'o', '__output'};
maxval={0,2,8,1,0};
minval={0,2,0,0,0};
istoggle=[0,1,1,1,0];
was_set=istoggle * 0;
paramtype={'InputFile','Integer','Integer','Double','OutputFile'};
% identify the input arrays and assign them to the arguments as stated by the user
if ~iscell(Inputs)
Inputs = {Inputs};
end
NumReqOutputs=1; nextinput=1; nextoutput=1;
  for ii=1:size(arglist,1)
  wasmatched=0;
  for jj=1:size(narglist,1)
   if strcmp(arglist{ii,1},narglist{jj,1})  % a given argument was matched to the possible arguments
     wasmatched = 1;
     was_set(jj) = 1;
     if strcmp(narglist{jj,2}, '__input')
      if (nextinput > length(Inputs)) 
        error(['Input ' narglist{jj,1} ' has no corresponding input!']); 
      end
      narglist{jj,2} = 'OK_in';
      nextinput = nextinput + 1;
     elseif strcmp(narglist{jj,2}, '__output')
      if (nextoutput > nargout) 
        error(['Output nr. ' narglist{jj,1} ' is not present in the assignment list of outputs !']); 
      end
      if (isempty(arglist{ii,2}))
        narglist{jj,2} = 'OK_out';
      else
        narglist{jj,2} = arglist{ii,2};
      end

      nextoutput = nextoutput + 1;
      if (minval{jj} == 0)  
         NumReqOutputs = NumReqOutputs - 1;
      end
     elseif isstr(arglist{ii,2})
      narglist{jj,2} = arglist{ii,2};
     else
        if strcmp(paramtype{jj}, 'Integer') & (round(arglist{ii,2}) ~= arglist{ii,2})
            error(['Argument ' arglist{ii,1} ' is of integer type but non-integer number ' arglist{ii,2} ' was supplied']);
        end
        if (minval{jj} ~= 0 | maxval{jj} ~= 0)
          if (minval{jj} == 1 & maxval{jj} == 1 & arglist{ii,2} < 0)
            error(['Argument ' arglist{ii,1} ' must be bigger or equal to zero!']);
          elseif (minval{jj} == -1 & maxval{jj} == -1 & arglist{ii,2} > 0)
            error(['Argument ' arglist{ii,1} ' must be smaller or equal to zero!']);
          elseif (minval{jj} == 2 & maxval{jj} == 2 & arglist{ii,2} <= 0)
            error(['Argument ' arglist{ii,1} ' must be bigger than zero!']);
          elseif (minval{jj} == -2 & maxval{jj} == -2 & arglist{ii,2} >= 0)
            error(['Argument ' arglist{ii,1} ' must be smaller than zero!']);
          elseif (minval{jj} ~= maxval{jj} & arglist{ii,2} < minval{jj})
            error(['Argument ' arglist{ii,1} ' must be bigger than ' num2str(minval{jj})]);
          elseif (minval{jj} ~= maxval{jj} & arglist{ii,2} > maxval{jj})
            error(['Argument ' arglist{ii,1} ' must be smaller than ' num2str(maxval{jj})]);
          end
        end
     end
     if ~strcmp(narglist{jj,2},'OK_out') &  ~strcmp(narglist{jj,2},'OK_in') 
       narglist{jj,2} = arglist{ii,2};
     end
   end
   end
   if (wasmatched == 0 & ~strcmp(arglist{ii,1},''))
        error(['Argument ' arglist{ii,1} ' is not a valid argument for this function']);
   end
end
% match the remaining inputs/outputs to the unused arguments and test for missing required inputs
 for jj=1:size(narglist,1)
     if  strcmp(paramtype{jj}, 'Toggle')
        if (narglist{jj,2} ==0)
          narglist{jj,1} = ''; 
        end;
        narglist{jj,2} = ''; 
     end;
     if  ~strcmp(narglist{jj,2},'__input') && ~strcmp(narglist{jj,2},'__output') && istoggle(jj) && ~ was_set(jj)
          narglist{jj,1} = ''; 
          narglist{jj,2} = ''; 
     end;
     if strcmp(narglist{jj,2}, '__input')
      if (minval{jj} == 0)  % meaning this input is required
        if (nextinput > size(Inputs)) 
           error(['Required input ' narglist{jj,1} ' has no corresponding input in the list!']); 
        else
          narglist{jj,2} = 'OK_in';
          nextinput = nextinput + 1;
        end
      else  % this is an optional input
        if (nextinput <= length(Inputs)) 
          narglist{jj,2} = 'OK_in';
          nextinput = nextinput + 1;
        else 
          narglist{jj,1} = '';
          narglist{jj,2} = '';
        end;
      end;
     else 
     if strcmp(narglist{jj,2}, '__output')
      if (minval{jj} == 0) % this is a required output
        if (nextoutput > nargout & nargout > 1) 
           error(['Required output ' narglist{jj,1} ' is not stated in the assignment list!']); 
        else
          narglist{jj,2} = 'OK_out';
          nextoutput = nextoutput + 1;
          NumReqOutputs = NumReqOutputs-1;
        end
      else % this is an optional output
        if (nargout - nextoutput >= NumReqOutputs) 
          narglist{jj,2} = 'OK_out';
          nextoutput = nextoutput + 1;
        else 
          narglist{jj,1} = '';
          narglist{jj,2} = '';
        end;
      end
     end
  end
end
if nargout
   varargout = cell(1,nargout);
else
  varargout = cell(1,1);
end
global KhorosRoot
if exist('KhorosRoot') && ~isempty(KhorosRoot)
w=['"' KhorosRoot];
else
if ispc
  w='"C:\Program Files\dip\khorosBin\';
else
[s,w] = system('which cantata');
w=['"' w(1:end-8)];
end
end
[varargout{:}]=callKhoros([w 'igamut"  '],Inputs,narglist);