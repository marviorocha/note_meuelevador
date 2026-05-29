FROM postgres:13-alpine

# Caso queira configurar o locale (opcional)
# ENV LANG pt_BR.utf8

# Você pode adicionar scripts SQL para rodar na inicialização
# COPY ./init.sql /docker-entrypoint-initdb.d/
