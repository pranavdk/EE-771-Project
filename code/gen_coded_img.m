for i=1:20
	t = 2;
    filename = strcat('video',num2str(i),'.mat');
    load(filename);
    s = size(array);
    rvid = reshape(array(:,:,1,:),[s(1) s(2) s(4)]);
    gvid = reshape(array(:,:,2,:),[s(1) s(2) s(4)]);
    bvid = reshape(array(:,:,3,:),[s(1) s(2) s(4)]);
    rcoded = zeros(s(1),s(2));
    bcoded = zeros(s(1),s(2));
    gcoded = zeros(s(1),s(2));
    timemap = randi([1 36],[s(1) s(2)]);
    for j=1:s(1)
        for k=1:s(2)
        	for l=1:t
                ind = mod(timemap(j,k)-1+l-1, 36) + 1;
	            rcoded(j,k) = rcoded(j,k)+rvid(j,k,ind);
	            gcoded(j,k) = gcoded(j,k)+gvid(j,k,ind);
	            bcoded(j,k) = bcoded(j,k)+bvid(j,k,ind);
            end
        end
    end
    rcoded = rcoded/t;
    gcoded = gcoded/t;
    bcoded = bcoded/t;
    
    coded = cat(3,rcoded,gcoded,bcoded);
    coded_filename = strcat('coded',num2str(i),'_',num2str(t),'.mat');
    save(coded_filename, 'coded');
end