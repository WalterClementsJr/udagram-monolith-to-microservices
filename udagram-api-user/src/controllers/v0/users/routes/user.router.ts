import {Request, Response, Router} from 'express';

import {User} from '../models/User';
import {AuthRouter} from './auth.router';

const router: Router = Router();

router.use('/auth', AuthRouter);

router.get('/');

router.get('/:id', async (req: Request, res: Response) => {
  const {id} = req.params;
  const item = await User.findByPk(id);

  console.debug(req.id, "findByPk", item);
  res.send(item);
});

export const UserRouter: Router = router;