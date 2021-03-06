function res = weights_to_csv(weights,outfile);
% res = function weights_to_csv(weights,outfile);
  fnum = fopen(outfile,'w');
  fnames = weights.feature_names;
  for i=1:length(weights.class_names);
    fprintf(fnum,',%s',weights.class_names{i});
  end;
  fprintf(fnum,'\n');
  for i=1:length(fnames);
    fprintf(fnum,'%s',fnames{i});
    for j=1:length(weights.weights(i,:));
      fprintf(fnum,',%4.4f',weights.weights(i,j));
    end;
    fprintf(fnum,'\n');
  end;
  for i= (length(fnames)+1):size(weights.weights,1);
    for j=1:length(weights.weights(i,:));
      fprintf(fnum,',%4.4f',weights.weights(i,j));
    end;
    fprintf(fnum,'\n');
  end;
  fclose(fnum);
  res = 0;  
